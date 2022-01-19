library(DT)
library(shiny)
library(plotly)
library(tidyverse)
library(shinydashboard)
library(shinyWidgets)

ui <- dashboardPage(skin= "purple",
                    dashboardHeader(title = "Daylight Saving Time & Nashville"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Traffic Accidents", tabName = "traffic_accidents", icon = icon("car")
                                 ),
                        
                        menuItem("Police Calls", tabName = "calls", icon = icon("phone")
                                 ),
                        
                        pickerInput("year", label = h2("Year"),
                                    choices = unique(sort(format(traffic$date_and_time, format="%Y")
                                                          )
                                                     ),
                                    options = list(`actions-box` =TRUE),
                                    multiple=TRUE
                        ),
                        
                      
                        radioButtons(
                          "tf",
                          "Timeframe",
                          choices = c("Weekly",
                                      "Daily"),
                          selected = NULL,
              
                        )
                        
                        
                      )
                    ), 
                    
                    dashboardBody(
                      
                      tabItems( 
                        # First tab content
                        tabItem(tabName = "traffic_accidents",
                                column(width=6,
                                       plotlyOutput("monthly_trafficPlot", height=350),
                                       br(),
                                       box(DT::dataTableOutput("monthly_table"),width=13,height=400),
                                       
                                       fluidRow(
                                         valueBoxOutput("progressBox"),
                                         valueBoxOutput("approvalBox"),
                                         valueBoxOutput("funBox")
                                         
                                       )
                                ),
                                
                                column(width=6,
                                       tabBox(width='125%',height=430,
                                              title = tagList(icon("calendar-alt")),
                                              # The id lets us use input$tabset1 on the server to find the current tab
                                              id = "tabset1",
                                              tabPanel("Year", 
                                                       plotlyOutput("boxplotYear")
                                              )
                                              ,
                                              tabPanel("Month", br(),
                                                       plotlyOutput("boxplotMonth")
                                              ) 
                                              
                                       ),
                                       
                                       
                                       
                                       
                                       tabBox(width='125%',
                                              title = tagList(icon("cloud-sun-rain"),icon("adjust")),
                                              # The id lets us use input$tabset1 on the server to find the current tab
                                              id = "tabset2", 
                                              tabPanel("Weather", 
                                                       plotlyOutput("weather_plot")),
                                              tabPanel("Lighting", 
                                                       plotlyOutput("lighting_plot"))
                                       ),
                                       
                                       
                                )
                                
                                
                                
                        ),
                        tabItem(tabName ="calls")
                      )
                    )
)


server <- function(input, output) {
  
  monthly_traffic_filtered <-  reactive({
    traffic %>%
      filter(format(date_and_time, format="%Y") %in% input$year) %>% 
      group_by(date_and_time_formatted, format(date_and_time, format="%Y")) %>%
      rename(Year=`format(date_and_time, format = "%Y")`) %>% 
      summarize(frequency = n()) %>% 
      ungroup()
    
  })
  
  
  
  

  
  month_stats <-  reactive({
    traffic %>%
      filter(format(date_and_time, format="%Y") %in% input$year) %>% 
      group_by(date_and_time_formatted) %>%
      summarize("Number of injuries" = sum(as.numeric(number_of_injuries)),
                "Number of Vehicles Involved" = sum(as.numeric(number_of_motor_vehicles),na.rm=T),
                "Instances of Property Damage" = sum(property_damage, na.rm = T),
                "Instances of Hit and Run" = sum(hit_and_run, na.rm=T),
                "Max Number of Vehicles Involved" = max(as.numeric(number_of_motor_vehicles),na.rm = T)) %>% 
      rename(Month=date_and_time_formatted)
    
    
  })
  
  lighting_filtered <- reactive({
    traffic %>% 
      filter(format(date_and_time, format="%Y") %in% input$year) %>% 
      subset(illumination_description != "OTHER" & illumination_description != "UNKNOWN") %>%
      count(illumination_description) %>% 
      na.omit() 
    
  })
  
  
  weather_filtered <- reactive ({
    traffic %>% 
      filter(format(date_and_time, format="%Y") %in% input$year) %>%
      count(weather_description) %>% 
      na.omit()
    
  })
  
  month_pct <- reactive({
    traffic %>% 
      filter(format(date_and_time, format="%Y") %in% input$year) %>% 
      group_by(date_and_time_formatted) %>% 
      summarize(frequency = n()) %>%
      mutate(pct_change = (frequency/lag(frequency)-1) *100) %>% 
      pluck(3,3, round,1)
    
  })
  
  week_pct <- reactive({
    traffic %>% 
      filter(format(date_and_time, format="%Y") %in% input$year) %>% 
      filter(date_and_time_formatted=="Mar") %>% 
      group_by(month=ceiling_date(date_and_time, "week", week_start = getOption("lubridate.week.start",7))) %>% 
      summarize(frequency=n()) %>% 
      mutate(pct_change = (frequency/lag(frequency)-1) *100) %>% 
      pluck(3,3, round, 1)
    
  })
  
  
  output$monthly_trafficPlot <- renderPlotly({
    if (input$year) {   
     monthly_traffic_filtered() %>%
      plot_ly(x=~factor(date_and_time_formatted, levels = month.abb),
              y=~frequency,source="month",
              type="scatter",
              mode="lines",
              color=~Year) %>%
      layout(xaxis=list(title="")
             )
    }


    if (input$tf == "Weekly") {
      traffic %>%
      filter(format(date_and_time, format="%Y") %in% input$year) %>%
      group_by(format(date_and_time, format="%U")) %>%
      rename(Week=`format(date_and_time, format = "%U")`) %>%
      summarize(frequency = n()) %>%
      ungroup() %>%
      plot_ly(x=~Week,y=~frequency,type="scatter", mode="lines+markers")
    }

    if (input$tf == "Daily") {
      traffic %>%
      filter(format(date_and_time, format="%Y") %in% input$year) %>%
      group_by(format(date_and_time, format="%j")) %>%
      rename(Day=`format(date_and_time, format = "%j")`) %>%
      summarize(frequency = n()) %>%
      ungroup() %>%
      plot_ly(x=~Week,y=~frequency,type="scatter", mode="lines+markers")

    }
})


  
  
  output$monthly_table = DT::renderDataTable({
    all <- month_stats()
    
    click <- event_data("plotly_click", source="month")
    if(is.null(click)) return(all)
    
    all %>%
      filter(date_and_time_formatted==click$x)
    
  },
  extensions= 'Buttons',
  options= list(pageLength=6, 
                dom = 'Bfrtip', 
                buttons=list(
                  
                  list(   #Can't get it to work
                    extend = "collection",
                    text = 'Show all',
                    action = function ( e, dt, node, config ) {
                      if(is.null(click)) return(all);
                    }
                  )
                )
  )
  )
  
  
  output$progressBox <- renderValueBox({
    valueBox(
      "5%", "Avg. increase in # of incidents (from Feb to March)", icon = icon("list"),
      color = "purple"
    )
  })
  
  
  output$approvalBox <- renderValueBox({
    valueBox(
      paste0(month_pct(),"%"),
      "Change in # of incidents this year (from Feb to March)", icon = icon("car-crash"),
      color = "yellow")
    
  })
  
  output$funBox <- renderValueBox({
    valueBox(
      paste0(week_pct(), "%"),
      "Percent change (from 1st week to 2nd week in March)", icon = icon("chart-line"),
      color = "blue"
    )
  })
  
  
  output$boxplotYear <- renderPlotly({
    traffic %>% 
      filter(format(date_and_time, format="%Y") %in% input$year) %>%
      group_by(date_and_time_formatted) %>% 
      summarize(`Number of Incidents` = n()) %>% 
      plot_ly(y=~`Number of Incidents`, type = "box") %>% 
      layout(title="Average Number of Incidents by Year",
             xaxis = list(showticklabels = F)
      )
    
  })
  
  output$boxplotMonth <- renderPlotly({
    traffic %>% 
      filter(date_and_time_formatted=="Mar")
    group_by(date_and_time_formatted) %>% 
      summarize(`Number of Incidents` = n()) %>% 
      plot_ly(y=~`Number of Incidents`, type = "box") %>% 
      layout(title="Average Number of Incidents by Year",
             xaxis = list(showticklabels = F)
      )
    
  })
  
  output$weather_plot <- renderPlotly({
    weather_filtered() %>% 
      plot_ly(x=~weather_description, y=~n, type="bar")
  })
  
  output$lighting_plot <- renderPlotly({
    lighting_filtered() %>% 
      plot_ly(x=~illumination_description, y=~n, type="bar")
  })
}






shinyApp(ui, server)


