library(shiny)
library(RCurl);
library(rjson);

api.key <- scan("api_key.txt", what=character(), quiet=TRUE);

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  });
  output$statsQuery <- renderText({
    if(input$apikey != ""){
      api.key <- input$apikey;
    }
    requestURL <- "https://statisticsnz.azure-api.net/nzdotstat/v1.0/odata/Catalogue?";
    requestParams <- c("subscription-key"=api.key,
                       "$expand"=input$expand,
                       "$filter"=input$filter,
                       "$select"=input$select,
                       "$order"=input$orderby,
                       "$top"=input$top,
                       "$skip"=input$skip,
                       "$count"=input$count
                       );
    requestParams <- requestParams[requestParams != ""];
    data.recursiveList <- format(fromJSON(getURL(url=paste0(requestURL,paste(names(requestParams),requestParams,sep="=",collapse="&")))));
    
  });
  
})
