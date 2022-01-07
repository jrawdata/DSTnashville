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
                        menuItem("Map", tabName = "widgets", icon = icon("map"))
                      )
                    ),
                    
                    dashboardBody(
                      tabItems( 
                        # First tab content
                        tabItem(tabName = "dashboard",
                                fluidRow(
                                  box(plotOutput("monthly_trafficPlot", height = 250)),
                                  
                                  box(title = "Title 1", width = 4, height = 250, background = "light-blue",
                                      "placeholder for graph")
                                      
                                ),
                                fluidRow(
                                  box(tableOutput("monthly_traffic_summaryTable")),
                                  
                                  # Dynamic valueBoxes
                                  valueBoxOutput("progressBox"),
                                  
                                  valueBoxOutput("approvalBox")
                                ),
                                fluidRow(
                                  # Clicking this will increment the progress amount
                                  box(width = 4, actionButton("count", "Increment progress")),
                                  
                                  box(plotOutput("top10_tencodePlot", height = 250))
                                  
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
