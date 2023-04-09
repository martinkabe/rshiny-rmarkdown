shinyApp(
  ui = fluidPage(
    textAreaInput(inputId = "txtInput", label = NULL),
    sliderInput("slider", "Slider", 1, 100, 50),
    downloadButton("report", "Generate report")
  ),
  server = function(input, output) {
    
    rv<-reactiveValues()
    
    observe({
      req(input$slider)
      rv$n<-input$slider
    })
    
    observe({
      req(input$txtInput)
      rv$txt<-input$txtInput
    })
    
    output$report <- downloadHandler(
      # For PDF output, change this to "report.pdf"
      filename = "report.html",
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        fileConn<-file("report.Rmd")
        writeLines(
          glue::glue(
            '
            ---
            title: "Dynamic report"
            output: html_document
            ---

            
            ```{{r}}
            print("{rv$txt}")
            ```
            
            ```{{r}}
            # The `reactiveValues` object is available in the document.
            {rv$n}
            ```
            
            A plot of `{rv$n}` random points.
            
            ```{{r}}
            plot(rnorm({rv$n}), rnorm({rv$n}))
            ```
            '
          ),
          fileConn
        )
        close(fileConn)
        
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy("report.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(
          n = input$slider,
          txt = input$txtInput
        )
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
  }
)