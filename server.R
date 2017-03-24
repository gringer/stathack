library(shiny);
library(RCurl);
library(rjson);

api.key <- "";
if(file.exists("api_key.txt")){
  api.key <- scan("api_key.txt", what=character(), quiet=TRUE);
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  });
  output$statsQuery <- renderDataTable({
    if(input$apikey != ""){
      api.key <- input$apikey;
    }
    requestURL <- "https://statisticsnz.azure-api.net/nzdotstat/v1.0/odata/";
    requestParams <- c("subscription-key"=api.key,
                       "$expand"=input$expand,
                       "$filter"=input$filter,
                       "$select"=input$select,
                       "$order"=input$orderby,
                       "$top"=input$top,
                       "$skip"=input$skip,
                       "$count"=tolower(str(input$count))
                       );
    requestParams <- requestParams[requestParams != ""];
    codeID <- "Catalogue";
    if(input$tablecode != ""){
      codeID <- paste0("TABLECODE",input$tablecode);
    }
    result <- fromJSON(getURL(url=paste0(requestURL,codeID,"?",
                                         paste(names(requestParams),
                                               requestParams,sep="=",collapse="&"))))$value;
    
    res.table <- sapply(result,function(x){data.frame(x,stringsAsFactors = FALSE)});
    return(data.frame(t(res.table)));
  });
  output$statsGraph <- renderPlot({
    if(input$apikey != ""){
      api.key <- input$apikey;
    }
    requestURL <- "https://statisticsnz.azure-api.net/nzdotstat/v1.0/odata/";
    requestParams <- c("subscription-key"=api.key,
                       "$expand"=input$expand,
                       "$filter"=input$filter,
                       "$select"=input$select,
                       "$order"=input$orderby,
                       "$top"=input$top,
                       "$skip"=input$skip,
                       "$count"=tolower(str(input$count))
    );
    requestParams <- requestParams[requestParams != ""];
    codeID <- "Catalogue";
    if(input$tablecode != ""){
      codeID <- paste0("TABLECODE",input$tablecode);
    }
    result <- fromJSON(getURL(url=paste0(requestURL,codeID,"?",
                                         paste(names(requestParams),
                                               requestParams,sep="=",collapse="&"))))$value;
    
    res.df <- data.frame(t(sapply(result,function(x){data.frame(x,stringsAsFactors = FALSE)})));
    print(range(as.numeric(res.df$Value)));
    hist(as.numeric(res.df$Value));
  });
})
