#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer<-function(input, output) {
  
  top10_tencode_filtered <- reactive({
    calls %>% 
      group_by(tencode) %>% 
      summarize(count = n()) %>%
      top_n(n =10, wt= count) 
  })
  

  set.seed(122)
  histdata <- rnorm(500) 
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
  
  output$progressBox <- renderValueBox({
    valueBox(
      paste0(25 + input$count, "%"), "Progress", icon = icon("list"),
      color = "purple"
    )
  })
  
  output$approvalBox <- renderValueBox({
    valueBox(
      "80%", "Approval", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  output$top10_tencodePlot <- renderPlot({
    top10_tencode_filtered() %>% 
      ggplot(aes(x=tencode, y=count)) +
      geom_col()
  })
}

