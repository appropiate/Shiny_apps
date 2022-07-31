#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Set working directory
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))

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
library(magrittr)
library(rvest)
library(maps)
library(ggplot2)
library(RColorBrewer)
library(ggiraph)



#------------------- Read in diabetes dataset and the RF model_diabetes
model_diabetes <- readRDS("model_diabetes.rds")
diabetes.dataset <- read.csv("diabetes.txt", stringsAsFactors = T)
levels(diabetes.dataset$diabetes) <- c("No", "Yes")

# ---------------------- Exporting and cleaning world data
    world_data <- readRDS("world.rds")# Contains map
    world_data2 <- read.csv("countries_codes_and_coordinates.csv", header=T) # contains ISO3
    
    # remove space from ISO3 codes
    world_data2$Alpha.3.code <- sapply(world_data2$Alpha.3.code,function(x){gsub(" ","",x)})
    
    # match some  important country names between both datasets
    old_names <- c("Antigua",   "UK","Iran"  ,
                   "Russia","USA" ,"Venezuela")
    
    new_names <- c("Antigua and Barbuda","United Kingdom"  ,"Iran, Islamic Republic of", 
                   "Russian Federation", "United States","Venezuela, Bolivarian Republic of")
    
    for (i in 1:length(old_names)){
      world_data$region[world_data$region == old_names[i]] <- new_names[i]}
    
    # Add ISO3 codes to world_data from world_data2:
    world_data["ISO3"] <- world_data2$Alpha.3.code[match(world_data$region,world_data2$Country)]
    head(world_data)
    
    ## Dataset on world diabetes prevalence
    dfprev <- read.csv("diabetesPrevalence.csv", header = T)
    dfprev <- dfprev[,c("Country.Name","Country.Code","X2011","X2021")]
    colnames(dfprev) <- c("country", "ISO3","y2011","y2021")
    
    
    # remove countries not present in world_data
    dfprev <- dfprev[which(dfprev$ISO3%in%world_data$ISO3),]
    
    
    # Add year columns to world_data:
    world_data["y2011"] <- dfprev[,"y2011"][match(world_data$ISO3,dfprev$ISO3)]
    world_data["y2021"] <- dfprev[,"y2021"][match(world_data$ISO3,dfprev$ISO3)]



###################################################################################
# User interface                   
###################################################################################

# Define UI for application 
ui <- fluidPage(
        title = "Disease predictors with Shiny",
       
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
                            class = "btn btn-primary" )
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
                                 actionLink("link_to_disclaimer", "Disclaimer"),
                                 HTML("<br>"),
                                 imageOutput("emoji")# emoji dependent on prediction)
                                ), # TabPanel
                      
                      tabPanel("Prediction algorithm",
                               tags$iframe(
                                 src = "diabetes_modelPerformance.html",
                                 width="100%", 
                                 height="950",
                                 scrolling="no",
                                 seamless="seamless",
                                 frameBorder="0")   
                      ),# TabPanel
                       
                       tabPanel("Dataset",
                                
                                hr(),
                                fluidRow(
                                  style = "height:40hv",
                                tags$iframe(
                                  src = "diabetes_summary.html",
                                   width="100%", 
                                   height="525",
                                  scrolling="yes",
                                  seamless="seamless",
                                  frameBorder="0"),
                                hr(),
                                HTML('<h3> <b> Plot predictors against diabetes </b> </h3>'),
                                HTML("<br>")
                                ), # fluidRow
                                selectInput("boxplot",
                                            "Choose predictor", 
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
                                           height="600"
                                           ),
                                downloadButton("download", "Download boxplot"),
                                HTML("<br>"),
                                HTML("<br>"),
                                HTML('<h3> <b> Browse through the data </b> </h3>'),
                                HTML("<br>"),
                                DT::dataTableOutput("diabetes_table",
                                                    height = "25%"),
                                HTML("<br>"),
                                HTML("<br>")
                                
                                
                               ), # TabPanel
                      
                      tabPanel("Diabetes Worldwide",
                               hr(),
                               HTML('<h3> <b> Diabetes prevalence</b> </h3>'),
                               HTML("See actual and past prevalence of diabetes by country in the interactive map below"),
                               hr(),
                                  # Input for interactive map
                               selectInput(inputId = "year",
                                            label = "Choose Year:",
                                            choices = list("2011" = "y2011", 
                                                           "2021" = "y2021"),
                                            selected = "y2011"),
                               # Output: interactive world map
                               girafeOutput("disPlot",
                                            height="600"),
                               HTML('<h3> <b> Further information on Diabetes</b> </h3>'),
                              
                                HTML("<ul>
                                      <li><a href = 'https://www.diabetes.no/'><b>Norwegian Diabetes Association</b></a></li>
                                      <li><a href = 'https://www.easd.org/'><b>European Association for the Study of Diabetes</b></a></li>
                                      <li><a href = 'https://www.diabetes.org/'><b>American Diabetes Association</b></a></li>
                                     </ul>"),
                                hr() ,
                               # Video on Diabetes prevalence
                               HTML('<iframe 
                                width="560"   
                                height="315"
                                src="https://www.youtube.com/embed/76VTcfCzRfo"
                                frameborder="0"
                                allow="accelerometer; 
                                      autoplay;
                                      encrypted-media; 
                                      gyroscope;
                                      picture-in-picture;"></iframe>'),
                               hr() 
                              
                            
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
           y_label <<- "Pregnancies"
         } else if(input$boxplot == "glucose"){
           y_label <<- "Fasting glucose (mg/dL)"
         } else if(input$boxplot == "pressure"){
           y_label <<- "Pressure (mm Hg)"
         }else if(input$boxplot == "triceps"){
           y_label <<- "Triceps skin fold (mm)"
         }else if(input$boxplot == "insulin"){
           y_label <<- "Insulin (U/mL)"
         }else if(input$boxplot == "mass"){
           y_label <<- "BMI (Kg/m2)"
         }else if(input$boxplot == "pedigree"){
           y_label <<- "Pedigree function"
         }else{
           y_label <<- "Age (years)"
         }
  
       Color <<- match(input$boxplot , c("pregnant",
                                        "glucose", 
                                        "pressure", 
                                        "triceps", 
                                        "insulin", 
                                        "mass", 
                                        "pedigree", 
                                        "age"))
       par(mar=c(10,5,3,10)) 
       pval <<-t.test(diabetes.dataset[diabetes.dataset$diabetes == "No",input$boxplot],
                      diabetes.dataset[diabetes.dataset$diabetes == "Yes",input$boxplot])$p.value
       pval <<- signif(pval, digits = 3)
       
       (bxplot <<-boxplot( 
                   get(input$boxplot) ~ diabetes, 
                    data=diabetes.dataset, 
                    col = Color + 1, 
                    xlab = "Diabetic",
                    ylab = y_label,
                    main = bquote(bold("Non-diabetic vs diabetic patients,") ~ italic("pval") ~ .("<") ~ .(pval)),
                    cex.main = 1.5,
                    cex.lab = 2,
                    cex.axis = 1.5)
         )
         

       }, 
     height = 600, 
     width = 700)
     
     #Download button
 
     output$download <- downloadHandler(
       file = function(){paste(input$boxplot, "vs diabetes.png")}, # variable with filename
       content = function(file){
         png(file)
        { par(mar=c(6,8,6,8)) 
          boxplot( 
           get(input$boxplot) ~ diabetes, 
           data=diabetes.dataset, 
           col = Color + 1, 
           xlab = "Diabetic",
           ylab = y_label,
           main = bquote(bold("Non-diabetic vs diabetic patients,") ~ italic("pval") ~ .("<") ~ .(pval)),
           cex.main = 1.5,
           cex.lab = 2,
           cex.axis = 1.5)}
         dev.off()
       })
     
     # Create the interactive world map
     output$disPlot <- renderGirafe({
       
       # Select data to view
       ifelse(input$year == "y2011", 
              plotdf <- world_data[,names(world_data) != "y2021"], 
              plotdf <- world_data[,names(world_data) != "y2011"])
       
       names(plotdf)[8] <- "Year"
       
       # caption with the data source 
       caption <- "Source: World Development Indicators"
       
       #Specify the plot for the world map
       library(RColorBrewer)
       library(ggiraph)
       
       g <- ggplot() + 
         geom_polygon_interactive(data = subset(plotdf, lat >= -60 & lat <= 90), 
                                  color = "gray70",
                                  size = 0.1,
                                  aes(x = long, 
                                      y = lat, 
                                      group=group,
                                      fill =  Year,  
                                      tooltip = sprintf("%s<br/>%s", 
                                                        ISO3,
                                                        Year))) +
         scale_fill_gradientn(colours = brewer.pal(5,"YlOrRd"),
                              na.value = "white") +
         
         labs(fill =  ifelse(input$year == "y2011","2011" ,"2021"),
              caption = caption) +
         
         theme_bw() + 
         
         theme(axis.title = element_blank(),
               axis.text = element_blank(),
               axis.ticks = element_blank(),
               panel.grid.major = element_blank(),
               panel.grid.minor = element_blank(),
               panel.background = element_blank(),
               legend.position = "bottom",
               panel.border = element_blank(),
               strip.background = element_rect(fill="white",
                                               colour = "white"))
       
       ggiraph(code = print(g))
     })

}  # server  


# Run the application 
shinyApp(ui = ui, server = server)
