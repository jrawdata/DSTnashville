#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggthemes)

# Define UI for application that draws a histogram
ui <- dashboardPage(skin= "purple",
                    dashboardHeader(title = "Daylight Saving Time & Nashville"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Main", tabName = "dashboard", icon = icon("clock")),
                        
                        menuItem("Map", tabName = "widgets", icon = icon("map")),
                        
                        selectInput("radio", label = h2("Year"),
                                     choices = list("All" = 1, "2015" = 2, "2016" = 3, "2017" = 4,
                                                    "2018" = 5, "2018" = 6, "2019" = 7, "2020" = 8,
                                                    "2021" = 9), 
                                     selected = 1)
                      )
                    ),
                    
                    dashboardBody(
                      
                      tabItems( 
                        # First tab content
                        tabItem(tabName = "dashboard",
                                fluidRow(
                                  box(
                                    column(width=12,
                                         plotOutput("monthly_trafficPlot")
                                         )
                                    ),
                                   box(
                                  column(width=12,
                                        plotOutput("weekly_trafficPlot", height=200)
                                             
                                         )
                                         
                                  )
                                ),
                                fluidRow(
                                  box(tableOutput("monthly_traffic_summaryTable")),

                                  # Dynamic valueBoxes
                                  valueBoxOutput("progressBox"),

                                  valueBoxOutput("approvalBox")
                                ),
                                fluidRow(
                                 
                                  
                                  box(plotOutput("monthly_callPlot",))
                                  
                                )
                        ),
                        
                        # Second tab content
                        tabItem(tabName = "widgets",
                                h2("Widgets tab content",
                                   fluidRow(
                                     box(
                                       width = 4, background = "black",
                                       "A box with a solid black background"
                                     ),
                                     box(
                                       title = "Title 5", width = 4, background = "light-blue",
                                       "A box with a solid light-blue background"
                                     ),
                                     box(
                                       title = "Title 6",width = 4, background = "maroon",
                                       "A box with a solid maroon background"
                                     )
                                   ))
                        )
                      )
                    )
)
