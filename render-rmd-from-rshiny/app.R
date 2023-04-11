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
      filename = "report.docx",
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        fileConn<-file("report.Rmd")
        writeLines(
          glue::glue(
            '
            ---
            output:
              officedown::rdocx_document:
                toc: FALSE
            ---
            
            ```{{r setup, include=FALSE}}
            library(officedown)
            library(officer)
            library(flextable)
            # https://ardata-fr.github.io/officeverse/officedown-for-word.html#insert-sections
            # https://www.r-bloggers.com/2021/03/awesome-r-markdown-word-report-with-programmatically-inserted-headings-outputs-and/
            
            # set chunks defaults
            knitr::opts_chunk$set(
              echo = FALSE,
              warning = FALSE,
              message = FALSE,
              fig.cap = TRUE
            )
            # set flextable defaults
            set_flextable_defaults(
              font.family = "Arial", font.size = 9, 
              theme_fun = "theme_vanilla",
              big.mark="", table.layout="autofit"
            )
            ```
            
            ```{{r functions}}
            add_table<-function(bkm, label, style){{
              run_num <- run_autonum(
                seq_id = "tab",
                pre_label = "Table ", post_label = ". ",
                bkm = bkm, bkm_all = TRUE
              )
              block_caption(
                label = label,
                style = style,
                autonum = run_num
              )
            }}
            ```
            
            
            # {rv$txt}
            
            This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.
            
            When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
            
            ```{{r airquality}}
            # ft_example <- fp_text_lite(
            #   color = "red", bold = TRUE)
            add_table(
              bkm = "airquality_table",
              label = "Airquality table",
              style = "caption"
            )
            head(airquality, {rv$n})
            ```
            
            This is reference to `r run_reference(id = "airquality_table")`.
            
            And another table.
            
            ```{{r mtcars}}
            add_table(
              bkm = "mtcars_table",
              label = "mtcars table",
              style = "caption"
            )
            head(mtcars, {rv$n})
            ```
            
            This is reference to `r run_reference(id = "mtcars_table")`.
            
            ## Including Plots
            
            :::{{custom-style="mystyle1"}}
            This is formatted according to the _mystyle1_ format.
            :::
            
            :::{{custom-style="mystyle3"}}
            This format includes a border and it also works with an equation.
            $$Y = bX + c$$
            :::
            
            You can also embed plots, for example:
            
            ```{{r pressure}}
            plot(pressure)
            ```
            
            Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
            '
          ),
          fileConn
        )
        close(fileConn)
        
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy("report.Rmd", tempReport, overwrite = TRUE)
        
        docx_file <- tempfile(fileext = ".docx")
        
        # Set up parameters to pass to Rmd document
        # params <- list(
        #   n = input$slider,
        #   txt = input$txtInput
        # )
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file,
                          # params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
  }
)