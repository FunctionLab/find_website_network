#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(sigmaNet)
library(shiny)
library(magrittr)
require(igraph)
require(data.table)
#netvis.igraph = read_graph('/Genomics/ogtr04/jzthree/flyexpress/netvis.graphml',format='graphml')
setwd('/srv/shiny-server/')
#netvis.igraph = read_graph('netvis.graphml',format='graphml')
load('netvis.RData')
pred = fread('all.prob.withsymbol.txt')
logfc = fread('all.lfc.txt')[,2:283,with=F]
logfc$gene = pred$gene
validinsitu = fread('validinsitu',header = F)


range1.100 <- function(x){1 + 99*(x-min(x,na.rm = T))/(max(x,na.rm = T)-min(x,na.rm = T))}

colr <- colorRampPalette(c( "#440154FF","#482878FF", "#3E4A89FF", "#31688EFF", "#26828EFF", "#1F9E89FF", "#35B779FF", "#6DCD59FF", "#B4DE2CFF", "#FDE725FF"))(100)





sigmaFromIgraph<-function (graph, g, use_logfc=F, layout = NULL, width = NULL, height = NULL, 
                           elementId = NULL) 
{
  graph_parse <- igraph::as_data_frame(graph, what = "both")
  edges <- graph_parse$edges
  edges <- edges[, c("from", "to")]
  edges$id <- 1:nrow(edges)
  edges$size <- 1
  edges$from <- as.character(edges$from)
  edges$to <- as.character(edges$to)
  colnames(edges) <- c("source", "target", "id", "size")
  if (length(layout) == 0) {
    l <- igraph::layout_nicely(graph)
  }
  else {
    l <- layout
  }
  nodes <- graph_parse$vertices
  nodes$label <- row.names(nodes)
  nodes <- nodes[, "label", drop = FALSE]
  nodes <- cbind(nodes, l)
  colnames(nodes) <- c("label", "x", "y")
  nodes$id <- 1:nrow(nodes)
  nodes$size <- (0+(1:390 %in% validinsitu$V1)*4)
  nodes$x <- as.numeric(nodes$x)
  nodes$y <- as.numeric(nodes$y)
  if(use_logfc){
    nodes$color <- colr[round(range1.100(as.numeric(logfc[gene==g,1:282,with=F])[match(1:390,validinsitu$V1)]))]
  }
  else{
    nodes$color <- colr[round(range1.100(as.numeric(pred[gene==g,1:282,with=F])[match(1:390,validinsitu$V1)]))]
  }
  edges$color <- "#636363"
  edges$source <- nodes$id[match(edges$source, nodes$label)]
  edges$target <- nodes$id[match(edges$target, nodes$label)]
  if(use_logfc){
    nodes$label <- gsub("NA","not-in-prediction",paste(V(graph)$id,as.numeric(logfc[gene==g,1:282,with=F])[match(1:390,validinsitu$V1)]))
  }
  else{
    nodes$label <- gsub("NA","not-in-prediction",paste(V(graph)$id,as.numeric(pred[gene==g,1:282,with=F])[match(1:390,validinsitu$V1)]))
  }
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)
  graphOut <- list(nodes, edges)
  names(graphOut) <- c("nodes", "edges")
  options <- list(minNodeSize = 1, maxNodeSize = 3, minEdgeSize = 3, 
                  maxEdgeSize = 1, neighborEvent = "onClick", neighborStart = "clickNode", 
                  neighborEnd = "clickStage", doubleClickZoom = TRUE, mouseWheelZoom = TRUE)
  out <- jsonlite::toJSON(graphOut, pretty = TRUE)
  x <- list(data = out, options = options, graph = graph_parse)
  htmlwidgets::createWidget(name = "sigmaNet", x, width = width, 
                            height = height, package = "sigmaNet", elementId = elementId)
}




# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Network visualization of expression predictions"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectizeInput(
          'gene', label = 'Gene name', selected='x16', choices = sort(na.omit(pred$gene)),multiple=F,
          options = list()
        ),
        radioButtons("type", "Score type:",
                     c("Probability" = "prob",
                       "Log fold over background" = "logfc"))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        sigmaNetOutput('network', height = '600px')
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  output$network <- renderSigmaNet({
    sigmaFromIgraph(netvis.igraph, input$gene, use_logfc = (input$type=='logfc')) 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

