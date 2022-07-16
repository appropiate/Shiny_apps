library(DT)

ui <- basicPage(
  h2("The mtcars data"),
  DT::dataTableOutput("mytable")
)

server <- function(input, output) {
  output$mytable = DT::renderDataTable({
    mtcars
  })
}

shinyApp(ui, server)status