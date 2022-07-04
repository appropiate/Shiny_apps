#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("united"),
                navbarPage(
                  # theme = 'cerulean', # <--- To use a theme, uncomment this
                  "My first app",
                  tabPanel("Navbar 1",
                           sidebarPanel(
                             tags$h3("Input:"),
                             textInput("txt1", "Given Name:",""), # txt1 will sent to the server
                             textInput("txt2", "Surname:", "") # txt2 will be sent to server
                           ), # sidebarPanel
                           mainPanel(
                                        h1("Header 1"),
                                        h4("Output 1"),
                                        verbatimTextOutput("txtout") # txtout is generated from the server 
                          
                           ) # mainPanel
                           ), # Navbar 1, tabPanel
                  tabPanel("Navbar 2", "This panel is intentionally left blank"),
                  tabPanel("Navbar 3","This panel is intentionally left blank")
                ) #navbarPage
                ) # fluidPage

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$txtout <- renderText({
    paste(input$txt1, input$txt2, sep = " ")
  })
} # server

# Run the application 
shinyApp(ui = ui, server = server)
