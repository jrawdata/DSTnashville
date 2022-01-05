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

# Define UI for application that draws a histogram
ui <- dashboardPage(skin= "purple",
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  
    dashboardBody(
      tabItems( 
        # First tab content
        tabItem(tabName = "dashboard",
                fluidRow(
                  box(title = "Title 1", width = 4, height = 250, background = "light-blue",
                      "placeholder for graph"),
                  
                  box(
                    title = "Controls",
                    sliderInput("slider", "Number of observations:", 1, 100, 50)
                  )
                ),
                fluidRow(
                  # A static valueBox
                  valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                  
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
