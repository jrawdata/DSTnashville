library(DT)
library(shiny)
library(plotly)
library(tidyverse)
library(shinydashboard)
  
ui <- dashboardPage(skin= "purple",
                    dashboardHeader(title = "Daylight Saving Time & Nashville"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Traffic Accidents", tabName = "traffic_accidents", icon = icon("car")),
                        
                        menuItem("Police Calls", tabName = "calls", icon = icon("phone")),
                        
                        selectInput("year", label = h2("Year"),
                                    # choices = list("All", "2015", "2016", "2017",
                                    #                "2018" , "2018", "2019", "2020",
                                    #                "2021"), 
                                    choices = list(  "All"='date_and_time between "2015-01-01T00:00:00" and "2021-12-31T23:59:59"', 
                                         "2015" = 'date_and_time > "2015-01-01" & date_and_time < "2015-12-31"',
                                         "2016" = 'date_and_time > "2016-01-01" & date_and_time < "2016-12-31"',
                                         "2017" = 'date_and_time > "2017-01-01" & date_and_time < "2017-12-31"',
                                         "2018" = 'date_and_time > "2018-01-01" & date_and_time < "2018-12-31"',
                                         "2019" = 'date_and_time > "2019-01-01" & date_and_time < "2019-12-31"',
                                         "2020" = 'date_and_time > "2020-01-01" & date_and_time < "2020-12-31"',
                                         "2021" = 'date_and_time > "2021-01-01" & date_and_time < "2021-12-31"'
                                    ),
                                    selected = 1)
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
                                       plotlyOutput("boxplot", height = 407), br(),
                                       
                                       
                                       tabBox(width='125%',
                                         title = tagList(icon("cloud-sun-rain"),icon("adjust"), "tabBox status"),
                                         # The id lets us use input$tabset1 on the server to find the current tab
                                         id = "tabset1", height = "245px",
                                         tabPanel("Weather", 
                                                  plotlyOutput("weather_plot")),
                                         tabPanel("Lighting", 
                                                  plotlyOutput("lighting_plot"))
                                       ),
                                         # plotlyOutput("weather_plot", width='96.7%', height=436)
                                         # ,
                                         # plotlyOutput("lighting_plot",width=100)
                                         
                                       )
                                       
                                       
                                
                        ),
                        tabItem(tabName ="calls")
                      )
                    )
)
                    

  server <- function(input, output) {

    monthly_traffic_filtered <-  reactive({
      traffic %>%
        filter(input$year) %>% 
        group_by(date_and_time_formatted) %>%
        summarize(frequency = n())
    })

    month_stats <-  reactive({
    traffic %>%
      group_by(date_and_time_formatted) %>%
      summarize("Number of injuries" = sum(as.numeric(number_of_injuries)),
                "Number of Vehicles Involved" = sum(as.numeric(number_of_motor_vehicles),na.rm=T),
                "Instances of Property Damage" = sum(property_damage, na.rm = T),
                "Instances of Hit and Run" = sum(hit_and_run, na.rm=T),
                "Max Number of Vehicles Involved" = max(as.numeric(number_of_motor_vehicles),na.rm = T)
      )
  })
    options(width = 100) # Increase text width for printing table


    output$monthly_trafficPlot <- renderPlotly({
      monthly_traffic_filtered() %>%
        plot_ly(x=~factor(date_and_time_formatted, levels = month.abb),y=~frequency, source="month", type="scatter", mode="
          lines")

    })

    output$monthly_table = DT::renderDataTable({
      all <- month_stats()
      
      click <- event_data("plotly_click", source="month")
      if(is.null(click)) return(all)

      all %>%
        filter(date_and_time_formatted==click$x)

    },
    extensions= 'Buttons',
    options= list(pageLength=6, dom = 'bltpr', buttons=list("print","copy") )
    
    )

    output$TEST <-renderPrint({
        "HELLO"
    })
    
    output$progressBox <- renderValueBox({
      valueBox(
        paste0(25 + input$count, "%"), "2018 year increase in accidents", icon = icon("list"),
        color = "purple"
      )
    })
    
    
    output$approvalBox <- renderValueBox({
      valueBox(
        "%", "2018 year increase in calls", icon = icon("sun"),
        color = "yellow"
      )
    })
    
    output$funBox <- renderValueBox({
      valueBox(
        "%", "2018 year increase in calls", icon = icon("moon"),
        color = "blue"
      )
    })


    output$boxplot <- renderPlotly({
      traffic %>% 
        group_by(date_and_time_formatted) %>% 
        summarize(`Number of Incidents` = n()) %>% 
        plot_ly(y=~`Number of Incidents`, type = "box", name="") 
    })
    
    output$weather_plot <- renderPlotly({
      
      weather_conditions %>% 
        plot_ly(x=~weather_description, y=~n, type="bar")
    })
    
    output$lighting_plot <- renderPlotly({
      
      lighting_conditions %>% 
        plot_ly(x=~illumination_description, y=~n, type="bar")
    })
}


  shinyApp(ui, server)
  

  