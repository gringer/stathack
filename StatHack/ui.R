library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Stats NZ Data Browser"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("apikey", label = "API Key",placeholder = "Data access key"),
      textInput("expand", label = "Expand thingy"),
      textInput("filter", label = "FILTER query"),
      textInput("select", label = "SELECT query"),
      textInput("orderby", label = "Order By"),
      numericInput("top", "Display first n records", 
                   value=1000, step = 100),
      numericInput("skip", "Skip first n records", 
                   value=0, step = 100)
      #sliderInput("count", label = "Result count", min=1, max=1000, value=1000), 
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       textOutput("statsQuery")
    )
  )
))
