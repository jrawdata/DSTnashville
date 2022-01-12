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
library(plotly)

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
  
  
  monthly_calls_filtered <- reactive({
    calls %>% 
    group_by(call_rec_formatted) %>% 
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
 
 weekly_traffic_filtered <- reactive({
   jan_traffic %>%   
     group_by(week=week(jan_traffic$date_and_time)) %>% 
     summarize(Number_of_injuries=sum(as.numeric(number_of_injuries))
               )
   
 })
 
 weekly_calls_filtered <- reactive({
   jan_calls %>%
     group_by(week=week(jan_calls$call_rec)) %>%
     count()

 })



 output$weekly_callsPlot <- renderPlotly({
   weekly_calls_filtered() %>%
     plot_ly(x=week, y=n, type="bar")
 })

 
  
  output$progressBox <- renderValueBox({
    valueBox(
      paste0(25 + input$count, "%"), "2018 year increase in accidents", icon = icon("list"),
      color = "purple"
    )
  })
  
  output$approvalBox <- renderValueBox({
    valueBox(
      "%", "2018 year increase in calls", icon = icon("thumbs-up", lib = "glyphicon"),
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
    ggplot(aes(x=factor(date_and_time_formatted,levels = month.abb), y=frequency, group=1)) +
      geom_line() +
      geom_point(shape=21, color="black", fill="#69b3a2", size=6) +
      theme_few() +
      theme(legend.position = "none")
  })
  
  output$monthly_traffic_summaryTable <- renderTable({
    monthly_traffic_summary_filtered()
  })
  
  output$weekly_trafficPlot <- renderPlot({
    weekly_traffic_filtered() %>% 
      ggplot(aes(x= week,y=Number_of_injuries)) +
      geom_col() +
      theme_few() +
      theme(legend.position = "none")
  })
  
  output$monthly_callPlot <- renderPlot({
    monthly_calls_filtered() %>% 
      ggplot(aes(x=factor(call_rec_formatted,levels = month.abb), y=frequency, group=1)) +
      geom_line() +
      geom_point(shape=21, color="black", fill="#69b3a2", size=6) +
      theme_few() +
      theme(legend.position = "none")
  })
 
  
  output$TEST_TABLE <- renderPrint({
    keeprows <- round(input$plot_click$x) == as.numeric(TEST$week)
    TEST[keeprows, ]
    
      #nearPoints(TEST, input$plot_click)
      
  })
    
    

  
  
   
}
    