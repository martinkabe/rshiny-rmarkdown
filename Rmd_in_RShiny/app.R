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
  
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="main.css"),
    tags$script(src = "//yihui.org/js/math-code.js"),
    tags$script(src = "//mathjax.rstudio.com/latest/MathJax.js?config=TeX-MML-AM_CHTML"),
  ),
  
  div(
    id="main-div",
    actionButton("btnShowHide", "Edit"),
    shinyjs::hidden(
      div(
        id="form",
        textAreaInput(
          inputId = "txtInpt",
          label = NULL,
          width = "500px",
          height = "200px"
        )
      )
    ),
    uiOutput('markdown'),
    uiOutput("citeTbl"),
    tableOutput(outputId = "tblMtcars")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  rv<-reactiveValues()
  rv$eq1<-glue::glue(
    '# 1. Introduction
    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Vivamus luctus egestas leo.
    Phasellus rhoncus. Aliquam erat volutpat. Mauris elementum mauris vitae tortor.
    Nunc auctor. Ut tempus purus at lorem. Quis autem vel eum iure reprehenderit qui in 
    ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat 
    quo voluptas nulla pariatur? Fusce nibh. In rutrum.
    {tbls("Tab1", display="cite")} shows mtcars dataset.
    $$Pr(\\theta | y) = \\frac{{Pr(y | \\theta) Pr(\\theta)}}{{Pr(y)}}$$
    $$Pr(\\theta | y) \\propto Pr(y | \\theta) Pr(\\theta)$$
    ## 1.1 Linear Model
    $$Y \\sim X\\beta_0 + X\\beta_1 + \\epsilon$$
    $$\\epsilon \\sim N(0,\\sigma^2)$$'
  )
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
    # browser()
    HTML(markdown::markdownToHTML(text = tbls("Tab1", display="full"), fragment.only = TRUE))
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
