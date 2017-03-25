library(shiny)

rowCount.df <- read.csv("summary.table.csv", stringsAsFactors=FALSE);
tableCodes <- c("Catalogue",rowCount.df$TableCodeID);
tableNames <- rowCount.df$Description;
nameHead <- substring(tableNames,1,9);
nameTail <- substring(tableNames,nchar(tableNames)-9);
tableNames[nchar(tableNames) > 19] <-
  paste0(nameHead,"...",nameTail)[nchar(tableNames) > 19];
names(tableCodes) <- c("<summary>",sprintf("%s -- %s (%d rows)", rowCount.df$TableCodeID, 
                             tableNames, rowCount.df$RowCount));

# Define UI for application that draws a histogram
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel=titlePanel("Data Rover"),
  
  # Sidebar with a slider input for number of bins 
  sidebarPanel= sidebarPanel(
    textInput("apikey", label = "API Key",placeholder = "Data access key"),
    selectInput("tablecode",label = "Table Code", choices = tableCodes),
#      textInput("expand", label = "Expand"),
      textInput("filter", label = "FILTER query"),
      textInput("select", label = "SELECT query"),
      textInput("orderby", label = "Order By"),
      numericInput("top", "First n records", 
                   value=1000, step = 100),
#      numericInput("skip", "Skip first n records", 
#                   value=0, step = 100),
      checkboxInput("count", label = "Include record counts")
    ),
    
    # Show a plot of the generated distribution
    mainPanel=mainPanel(
      tags$h2("Data Summaries"),
      htmlOutput("dataTableName"),
      tabsetPanel(
        tabPanel("Table",
          dataTableOutput("statsQuery")),
        conditionalPanel("input.tablecode != 'Catalogue'",tabPanel("Graphs",
          plotOutput("statsGraph")))
    ))
  )
)
