#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(knitr)
library(captioner)
library(shinyjs)

# Define UI for application that draws a histogram

tbls<-captioner::captioner(prefix="Table")
figs<-captioner::captioner(prefix="Figure")

tbls("Tab1", "Some table with the data")

ui <- fluidPage(
  useShinyjs(),

  tags$script(src = "//yihui.org/js/math-code.js"),
  tags$script(src = "//mathjax.rstudio.com/latest/MathJax.js?config=TeX-MML-AM_CHTML"),
  
  actionButton("btnShowHide", "show / hide"),
  shinyjs::hidden(
    div(
      id="form",
      textAreaInput(inputId = "txtInpt", label = NULL)
    )
  ),
  
  uiOutput('markdown'),
  uiOutput("citeTbl"),
  tableOutput(outputId = "tblMtcars")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  rv<-reactiveValues()
  rv$eq1<-paste0(tbls("Tab1", display="cite"), " shows mrcars dataset.")
  shinyjs::hide(id = "myBox")
  
  observe({
    #req(rv$eq2)
    
    x=rv$eq1
    
    updateTextAreaInput(
      session = session,
      inputId = "txtInpt",
      value = x
    )
  })
  
  output$markdown <- renderUI({
    req(
      input$txtInpt
    )
    # `r tbls("Tab1", display="cite")`
    rv$eq2<-input$txtInpt
    withMathJax(HTML(markdown::markdownToHTML(text=rv$eq2, fragment.only = TRUE)))
    
  })
  
  output$citeTbl<-renderUI({
    HTML(markdown::markdownToHTML(tbls("Tab1", display="full"), fragment.only = TRUE))
  })
  
  observeEvent(input$btnShowHide, {
    shinyjs::toggle(id = "form")
  })
  
  output$tblMtcars<-renderTable({
    head(mtcars, 10)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)