library(shiny);
library(RCurl);
library(rjson);

rowCount.df <- read.csv("summary.table.csv", stringsAsFactors=FALSE);

api.key <- "";
if(file.exists("api_key.txt")){
  api.key <- scan("api_key.txt", what=character(), quiet=TRUE);
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$dataTableName <- renderUI({
    if(input$tablecode == "Catalogue"){
      tags$h3("Data Set Overview");
    } else {
      tags$h3(rowCount.df$Description[match(input$tablecode,rowCount.df$TableCodeID)]);
    }
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
                       #"$skip"=input$skip,
                       "$count"=tolower(str(input$count))
                       );
    requestParams <- requestParams[requestParams != ""];
    codeID <- "Catalogue";
    if(input$tablecode != "Catalogue"){
      codeID <- paste0("TABLECODE",input$tablecode);
    }
    requestCode <- paste0(requestURL,codeID,"?",
                          paste(names(requestParams),
                                requestParams,sep="=",collapse="&"));
    resultText <- getURL(url=requestCode);
    resultText <- gsub(":null",":\"\"",resultText); ## hack to work around "null" appearing in JSON
    result <- fromJSON(resultText)$value;
    res.table <- do.call(rbind, lapply(result, data.frame, stringsAsFactors=FALSE));
    return((res.table));
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
    if(input$tablecode != "Catalogue"){
      codeID <- paste0("TABLECODE",input$tablecode);
    }
    result <- fromJSON(gsub(":null",":\"\"",getURL(url=paste0(requestURL,codeID,"?",
                                         paste(names(requestParams),
                                               requestParams,sep="=",collapse="&")))))$value;
    res.df <- do.call(rbind, lapply(result, data.frame, stringsAsFactors=FALSE));
    write.csv(res.df,"res.csv");
    if(!is.null(res.df$Value)){
      hist(as.numeric(res.df$Value), main="Value", col="red");
    }
    barplot(table(res.df[,1]), main=colnames(res.df)[1]);
  });
})
