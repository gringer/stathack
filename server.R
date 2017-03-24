library(shiny);
library(RCurl);
library(rjson);

api.key <- "";
if(file.exists("api_key.txt")){
  api.key <- scan("api_key.txt", what=character(), quiet=TRUE);
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
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
    return((t(res.table)));
  });
  output$statsGraph <- renderPlot({
    par(mfrow=c(2,1));
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
    hist(as.numeric(res.df$Value), main="Value");
    barplot(table(unlist(res.df[,1])), main=colnames(res.df)[1]);
  });
})
