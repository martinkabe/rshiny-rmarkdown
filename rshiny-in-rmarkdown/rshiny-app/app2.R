library(shiny)

test_app<-function(rv){
  shinyApp(
    
    ui = fluidPage(
      actionButton(
        inputId = "btnRefresh",
        label = "Refresh!"
      ),
      plotOutput("pltHistogram")
    ),
    
    server = function(input, output) {
      
      output$pltHistogram<-renderPlot({
        req(
          rv$nRows,
          rv$nBins
        )
        
        input$btnRefresh
        
        x    = faithful[1:rv$nRows, 2]  # Old Faithful Geyser data
        bins = seq(min(x), max(x), length.out = rv$nBins + 1)
        
        # draw the histogram with the specified number of bins
        isolate({
          hist(
            x = x,
            breaks = bins,
            col = 'darkgray',
            border = 'white',
            main=isolate(rv$title)
          )
        })
        
      })
    },
    
    options = list(height = 500)
  )
}