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
  
  output$top10_tencodePlot <- renderPlotly({
    top10_tencode_filtered() %>% 
      plot_ly(top10_tencode,
              x=~tencode,
              y=~count,
              name="Tencodes-Top 10",
              type="bar"
      )  
  })
  
  output$monthly_trafficPlot <- renderPlotly({
    event.data <- event_data(event = "plotly_click")  
    
    monthly_traffic_filtered() %>% 
      plot_ly(x=~factor(date_and_time_formatted, levels = month.abb),y=~frequency, type="scatter", mode="
          lines"
              # , 
              # key = ~weekly_plots,
              # source = ~wk_plts
      )
  })
  
  # 
  # 
  # output$ratingPlot <- renderPlotly({
  #   event.data <- event_data(event = "plotly_selected", source = "imgLink")
  #   if (is.null(event.data)) {
  #     print("Click and drag events (i.e., select/lasso) to make the bar plot appear here")
  #     plot_ly(ice.cream.df, x = ~flavors, y = ~rating, type = "bar",
  #             text = ~paste("Flavor:", flavors)) %>%
  #       layout(title = paste("Ice Cream Ratings Given by Flavor"))
  #   } else {
  #     ice.cream <- ice.cream.df[ice.cream.df$images %in% event.data$key,]
  #     plot_ly(ice.cream, x = ~flavors, y = ~rating, type = "bar",
  #             text = ~paste("Flavor:", flavors), key = ~images, source = "imgLink")
  # 
  # 
  # 
  # 
  
  output$monthly_traffic_summaryTable <- renderTable({
    monthly_traffic_summary_filtered()
  })
  
  output$weekly_trafficPlot <- renderPlotly({
    weekly_traffic_filtered() %>% 
      plot_ly(x=~week, y=~Number_of_injuries, type = "bar")
  })
  
  output$monthly_callPlot <- renderPlotly({
    monthly_calls_filtered() %>% 
      plot_ly(x=~factor(call_rec_formatted,levels = month.abb), y=~frequency, type="scatter", mode="lines")
  })
  
  
  output$weekly_callsPlot <- renderPlotly({
    weekly_calls_filtered() %>%
      plot_ly(x=~week, y=~n, type="bar")
  })
  
 
  
  output$TEST_TABLE <- renderPrint({
    event_data("plotly_click")
    
    
    # keeprows <- round(input$plot_click$x) == as.numeric(TEST$week)
    # TEST[keeprows, ]
    
      #nearPoints(TEST, input$plot_click)
      
  })
    
    

  
  
   
}
    