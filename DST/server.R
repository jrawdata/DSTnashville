#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggthemes)

# Define server logic required to draw a histogram
shinyServer<-function(input, output) {
  
  top10_tencode_filtered <- reactive({
    calls %>% 
      group_by(tencode) %>% 
      summarize(count = n()) %>%
      top_n(n =10, wt= count) 
  })
  
  monthly_traffic_filtered <-  reactive({
    traffic %>% 
    group_by(date_and_time_formatted) %>% 
    summarize(frequency = n()) 
  })
  
 monthly_traffic_summary_filtered <- reactive({
   traffic %>% 
     filter(month(date_and_time) == 1) %>% 
     summarize("Number of injuries" = sum(as.numeric(number_of_injuries)),
               "Number of Vehicles Involved" = sum(as.numeric(number_of_motor_vehicles)),
               "Instances of Property Damage" = sum(property_damage, na.rm = T),
               "Instances of Hit and Run" = sum(hit_and_run),
               "Max Number of Vehicles Involved" = max(as.numeric(number_of_motor_vehicles),na.rm = T)
     )
   
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
      geom_col() +
      theme_few()  
  })
  
  output$monthly_trafficPlot <- renderPlot({
    monthly_traffic_filtered() %>% 
    ggplot(aes(x=factor(date_and_time_formatted,levels = month.name), y=frequency)) +
      geom_col() +
      theme_few() +
      theme(legend.position = "none")
  })
  
  output$monthly_traffic_summaryTable <- renderTable({
    monthly_traffic_summary_filtered()
  })
  
}

