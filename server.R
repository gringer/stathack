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
  values <- reactiveValues();
  values$requestCode <- "";
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
    if(requestCode != values$requestCode){
      values$requestCode <- requestCode;
      resultText <- getURL(url=requestCode);
      resultText <- gsub(":null",":\"\"",resultText); ## hack to work around "null" appearing in JSON
      result <- fromJSON(resultText)$value;
      res.df <- do.call(rbind, lapply(result, data.frame, stringsAsFactors=FALSE));
      values$data <- res.df;
    }
    return(values$data);
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
    requestCode <- paste0(requestURL,codeID,"?",
                          paste(names(requestParams),
                                requestParams,sep="=",collapse="&"));
    if(requestCode != values$requestCode){
      values$requestCode <- requestCode;
      resultText <- getURL(url=requestCode);
      resultText <- gsub(":null",":\"\"",resultText); ## hack to work around "null" appearing in JSON
      result <- fromJSON(resultText)$value;
      res.df <- do.call(rbind, lapply(result, data.frame, stringsAsFactors=FALSE));
      values$data <- res.df;
    }
    res.df <- values$data;
    if(!is.null(res.df$Value)){
      hist(as.numeric(res.df$Value), main="Value", col="red");
    }
    barplot(table(res.df[,1]), main=colnames(res.df)[1]);
  });
  output$downloadCSV <- downloadHandler(
    filename = function() { 
      paste0(input$tablecode, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(values$data, file);
    },
    contentType = "text/csv"
  )
  
})
