library(shiny)

rowCount.df <- read.csv("record.sizes.dotstat.txt");
tableCodes <- rowCount.df$TableCode;
names(tableCodes) <- sprintf("%s (%d rows)", rowCount.df$TableCode, 
                             rowCount.df$RowCount);

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Stats NZ Data Browser"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("apikey", label = "API Key",placeholder = "Data access key"),
      selectInput("tablecode",label = "Table Code", choices = tableCodes),
      textInput("expand", label = "Expand thingy"),
      textInput("filter", label = "FILTER query"),
      textInput("select", label = "SELECT query"),
      textInput("orderby", label = "Order By"),
      numericInput("top", "Display first n records", 
                   value=1000, step = 100),
      numericInput("skip", "Skip first n records", 
                   value=0, step = 100),
      checkboxInput("count", label = "Include record counts"), 
      numericInput("skip", "Skip first n records", 
                   value=0, step = 100)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       dataTableOutput("statsQuery"),
       plotOutput("statsGraph")
    )
  )
))
