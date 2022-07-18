#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(stringr)
library(shinythemes)
library(rmarkdown)
library(ggfortify)
library(dplyr)
library(knitr)
library(data.table)
library(DT)
library(C50)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Read in dataset and the RF model_diabetes
diabetes.dataset <- read.csv("diabetes.txt", stringsAsFactors = T)
levels(diabetes.dataset$diabetes) <- c("No", "Yes")

model_diabetes <- readRDS("model_diabetes.rds")


###################################################################################
# User interface                   
###################################################################################

# Define UI for application that draws a histogram
ui <- fluidPage(
        title = "Hola",
        tags$style( # output styles
          "#status {
          font-size:18px;
          color:black;
          font-weight: bold;
          display:block; }"),
        tags$style( # output styles
          "#explanation {
          font-size:22px;
          color:black;
          font-weight: bold;
          display:block; }"),
        tags$style( # output styles
          "#emoji {
          width = 10px; }"),
        
        theme = shinytheme("sandstone"),
        navbarPage(
           #theme = 'sandstone',
         "HEALTH PREDICTORS:",
         id="MainNavBar",
         tabPanel("Diabetes",
                  sidebarPanel(
                   tags$h3("Predictor inputs:"),
                   sliderInput(inputId = "pregnant", 
                                label = "Pregnancies", 
                                min = 0, 
                                max = 20,
                                value = 0),
                   numericInput(inputId ="glucose", 
                                label = "Fasting glucose (mg/dL)", 
                                value = 100),
                   numericInput(inputId ="pressure", 
                                label ="Dyastolic Pressure (mm Hg)", 
                                value = 50),
                   numericInput(inputId ="triceps", 
                                label ="Triceps Skin Fold (mm)", 
                                value = 25),
                   numericInput(inputId ="insulin", 
                                label ="Insulin (U/mL)", 
                                value = 150),
                   numericInput(inputId ="mass",
                                label ="Body Mass Index (kg/m2)", 
                                value = 30),
                   numericInput(inputId ="pedigree", 
                                label ="Diabetes pedigree function", 
                                value = 2),
                   numericInput(inputId ="age", 
                                label ="Age", 
                                value = 30),
                   actionButton(inputId ="submitbutton",
                                label ="Submit",
                                class = "btn btn-primary" ),
                  ), # sidebarPanel
                                 
                 mainPanel(
                   
                     tabsetPanel(type = "tabs",
                                 id = "panels",
                                 
                      # Tabsets  in mainPanel----     
                       tabPanel("Prediction",
                                 HTML('<h3> <b> Status/Output of the prediction for diabetes:</b> </h3>'
                                 ), # Status/Output Text Box
                                 # verbatimTextOutput('contents'),
                                 textOutput("status"),
                                 HTML("<br>"),
                                 tableOutput('tabledata'), # Prediction results table
                                 htmlOutput("explanation", container = span),
                                 HTML("<br>"),
                                 HTML("<br>"),
                                 imageOutput("emoji"),# emoji dependent on prediction)
                                 actionLink("link_to_disclaimer", "Disclaimer")
                                ), # TabPanel
                      
                      tabPanel("Prediction algorithm",
                               tags$iframe(
                                 src = "diabetes_modelPerformance.html",
                                 width="100%", height="800",
                                 scrolling="no",
                                 seamless="seamless",
                                 frameBorder="0")   
                      ),# TabPanel
                       
                       tabPanel("Dataset",
                                hr(),
                                tags$iframe(
                                  src = "diabetes_summary.html",
                                  width="100%", 
                                  height="500",
                                  scrolling="no",
                                  seamless="seamless",
                                  frameBorder="0"),
                                selectInput("boxplot",
                                            "Predictor to plot against diabetes", 
                                            choices = c("Pregnancies"= "pregnant",
                                                        "Fasting glucose (mg/dL)" = "glucose", 
                                                        "Pressure (mm Hg)" = "pressure", 
                                                        "Triceps skin fold (mm)" = "triceps", 
                                                        "Insulin (U/mL)" = "insulin", 
                                                        "BMI (Kg/m2)" = "mass", 
                                                        "Pedigree function" = "pedigree", 
                                                        "Age (years)" = "age"),
                                            selected = "glucose"),
                                plotOutput("myplot", 
                                           width="100%", 
                                           height="550"),
                                HTML("<br>"),
                                HTML("<br>"),
                                HTML('<h3> <b> Browse through the data </b> </h3>'),
                                HTML("<br>"),
                                DT::dataTableOutput("diabetes_table"),
                                HTML("<br>"),
                                HTML("<br>")
                                
                                
                               )
                     
                
                              ) # tabsetPanel  
                           )# mainPanel
                                   
             ),#tabPanel
           
               navbarMenu("About",
                         tabPanel("Contact us",
                                   tags$iframe(
                                     src = "diabetes_contactUs.html",
                                     width="100%", height="500",
                                     scrolling="no",
                                     frameBorder="0")),
                          tabPanel("Disclaimer",
                                   tags$iframe(
                                     src = "diabetes_disclaimer.html",
                                     width="100%", height="500",
                                     scrolling="no",
                                     frameBorder="0") )
                         ) #NavbarMenu
          ) # NavbarPage  
      
        ) # fluidPage
                 

#################################################################################
# Server                           
#################################################################################

# Define server logic required to obtain predictions and probabilities of having diabetes
server <- function(input, output,session) {
  
  # Input Data
  datasetInput <- reactive({  
    
    df <- data.frame(
            # variable names in data set
            Name = c("pregnant",
                     "glucose",
                     "pressure",
                     "triceps",
                     "insulin",
                     "mass",
                     "pedigree",
                     "age"),
            # Values for variables  specified in inputs
            Value = as.character(c(input$pregnant,
                                   input$glucose,
                                   input$pressure,
                                   input$triceps,
                                   input$insulin,
                                   input$mass,
                                   input$pedigree,
                                   input$age)),
            stringsAsFactors = FALSE)
    
     # diabetes <- 0
     # df <- rbind(df, diabetes)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv("input.csv", header = TRUE)
    positive.prob <<- predict(model_diabetes,test,type="prob")[2]
    
    Output <- as.data.frame(cbind(as.character(predict(model_diabetes,test)), # prediction
                            paste(100*round(predict(model_diabetes,test,type="prob")[1],3),"%"), # "No" probability
                            paste(100*round(predict(model_diabetes,test,type="prob")[2],3),"%"))) # "Yes" probability
    
    colnames(Output) <- c("Diabetes prediction","'No' probability","'Yes' probability")
    print(Output)

    
  })

  
  # Status of the prediction calculation
  output$status <- renderText(if (input$submitbutton > 0 ) { 
                    "Diabetes prediction complete!" 
                    } else {
                     "Specify inputs for each predictor and click on 'Submit'!"
                       }
                    )
              

   

  # Prediction results table
    output$tabledata <- renderTable({
                           if (input$submitbutton > 0) { 
                              isolate(datasetInput()) 
                             } 
                        })
    
  # Explanation of prediction
    output$explanation <- renderText({
                            test <- read.csv("input.csv", header = TRUE)
                            positive.prob <<- predict(model_diabetes,test,type="prob")[2]
      
                            if (input$submitbutton > 0 &
                                positive.prob > 0.6) {
                                  ("<span style=\"color:red\">Looks like you have diabetes,
                                    inform and confirm with your doctor!</span>")  # Explanation text
                            } else if(input$submitbutton > 0 &
                                      positive.prob < 0.6 &
                                      positive.prob > 0.4){
                                        ("<span style=\"color:orange\">Not so sure if you have diabetes,
                                         consult your doctor!</span>")
                            } else if(input$submitbutton > 0 &
                                      positive.prob < 0.4){
                                        ("<span style=\"color:green\">You possibly do not have diabetes, 
                                          confirm with your doctor!</span>")
                                      
                              }
                           })        
    
  
  # Emoji images
     output$emoji <- renderImage({
                       if (input$submitbutton > 0 &
                           positive.prob > 0.6){
                         filename <- file.path('./www/sadEmoji.png')
                         list(src = filename,
                              style="display: block; 
                                    margin-left: auto;
                                    margin-right: auto;")
                         }
                       else if(input$submitbutton > 0 &
                               positive.prob < 0.6 &
                               positive.prob > 0.4){
                                 filename <- file.path('./www/neutralEmoji.png')
                                 list(src = filename,
                                      style="display: block; 
                                    margin-left: auto;
                                    margin-right: auto;")
                       } else if(input$submitbutton > 0 &
                                 positive.prob < 0.4){
                                  filename <- file.path('./www/happyEmoji.png')
                                  list(src = filename,
                                       style="display: block; 
                                          margin-left: auto;
                                          margin-right: auto;
                                          width = 50px;")
                          
                       } else {
                         filename <- file.path('./www/happyEmoji.png')
                         list(src = filename,
                              style="display: block; 
                                            margin-left: auto;
                                            margin-right: auto;")
                          
                        }
                    },
                       deleteFile = FALSE
                       )
     
     #Disclaimer link
     observeEvent(input$link_to_disclaimer, {
       newvalue <- "Disclaimer"
       updateNavbarPage(session,inputId="MainNavBar", selected = "Disclaimer")
     })
     
  ## TabPanel "DATASET"
     
     # Dataset table
     output$diabetes_table = DT::renderDataTable({
       diabetes.dataset
     })
         
    # Boxplot
     
     output$myplot <- renderPlot({
          if(input$boxplot == "pregnant"){
           y_label <- "Pregnancies"
         } else if(input$boxplot == "glucose"){
           y_label <- "Fasting glucose (mg/dL)"
         } else if(input$boxplot == "pressure"){
           y_label <- "Pressure (mm Hg)"
         }else if(input$boxplot == "triceps"){
           y_label <- "Triceps skin fold (mm)"
         }else if(input$boxplot == "insulin"){
           y_label <- "Insulin (U/mL)"
         }else if(input$boxplot == "mass"){
           y_label <- "BMI (Kg/m2)"
         }else if(input$boxplot == "pedigree"){
           y_label <- "Pedigree function"
         }else{
           y_label <- "Age (years)"
         }
  
       Color <- match(input$boxplot , c("pregnant",
                                        "glucose", 
                                        "pressure", 
                                        "triceps", 
                                        "insulin", 
                                        "mass", 
                                        "pedigree", 
                                        "age"))
       par(mar=c(10,5,3,10)) 
       pval <-t.test(diabetes.dataset[diabetes.dataset$diabetes == "No",input$boxplot],
                      diabetes.dataset[diabetes.dataset$diabetes == "Yes",input$boxplot])$p.value
       pval <- signif(pval, digits = 3)
       
       boxplot( 
         get(input$boxplot) ~ diabetes, 
          data=diabetes.dataset, 
          col = Color + 1, 
          xlab = "Diabetic",
          ylab = y_label,
          main = bquote(bold("Non-diabetic vs diabetic patients,") ~ italic("pval") ~ .("<") ~ .(pval)),
          cex.main = 1.5,
          cex.lab = 2,
          cex.axis = 1.5)
 ?brus     }, 
     height = 600, 
     width = 700)

}  # server  


# Run the application 
shinyApp(ui = ui, server = server)
