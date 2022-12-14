list.of.packages <- c("shiny", "gplots")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0){
  install.packages('shiny')
  install.packages("gplots")
  
}

library(shiny)
library(gplots)
# Define UI for app that draws a histogram ----
ui <- fillPage(
  titlePanel("  Heatmap of Lactate Correlating Genes"),
  sidebarLayout(position="left",
                sidebarPanel(
                  selectInput("pos.neg", h3("Positive or Negative Correlation"),
                              choices = list("Positive" = 1,
                                             "Negative" = 2,
                                             "Both" = 3),
                              selected = 1),
                    
                  sliderInput("cpm.cutoff", h3("CPM"), min = 0, max = 100, 
                              value = 20, step = 5),
                  sliderInput("cor.cutoff", h3("Cor."), min = 0, max = 100, 
                              value = 80, step = 1),
                  sliderInput("p.cutoff", h4("Cor. P"), min = 0, max = 1, 
                              value = .05, step = .01),
                  width = 3),
                
                mainPanel(
                  plotOutput(outputId = "distPlot", height=700, width=600)
                  
                )
  )
)


# Define server logic required to draw a histogram ----
server <- function(input, output) {

    git.dir      = "https://raw.githubusercontent.com/johncsantiago/Lactate-Correlation-Manuscript/master/Data/"
    LTD          = read.csv(paste0(git.dir,"LiverTraitData.csv"), row.names = 1)
    cpmdata      = read.csv(paste0(git.dir,"LacCorCpmData.csv"), row.names = 1)
    groups       = read.csv(paste0(git.dir,"Metadata.csv"), row.names = 1)
    annot        = read.csv(paste0(git.dir,"AnnotationData.csv"),row.names=1)
    lac.cor.data = read.csv(paste0(git.dir,"LacCorData.csv"), row.names = 1)
    lac.cor.p    = read.csv(paste0(git.dir,"LacCorP.csv"), row.names = 1)
      
    ##FunctionalGroups
    FG=c(rep("Adequate Function",5),rep("Intermediate Function",2),rep("Low Function",3))
    names(FG)=c("FV12","LV12","LV13","FV13","LV11","FN11","FN12","LN11","FN13","LN13")
    
    LacData=LTD$alactate
    names(LacData)=LTD$libraryID
    LacData=LacData[LTD$time==3]
    LacData=LacData[paste0(substring(names(FG),1,2),substring(names(FG),4,4))]
    names(LacData)=paste0(substring(names(LacData),1,2),"1",substring(names(LacData),4,4))
    cpm.0H=cpmdata[,names(FG)]
    cpm.0H=cpm.0H[apply(cpm.0H,1,sum)>0,]
      
    output$distPlot <- renderPlot({
      cpm.cutoff = input$cpm.cutoff
      cor.cutoff = (input$cor.cutoff)/100
      sig.cutoff = input$p.cutoff
      pos.or.neg = input$pos.neg
      
      ##trim for genes that meet cpm.cutoff
      cpm.genes=apply(cpm.0H,1,max)
      cpm.genes=names(cpm.genes[cpm.genes>cpm.cutoff])
      cordata=cpm.0H[cpm.genes,]
      
      ##trim for genes that meet sig.cutoff
      sig.genes=names(cor.p)[cor.p<sig.cutoff]
      cordata=cordata[intersect(row.names(cordata),sig.genes),]
      
      ##trim for genes that meet the cor.cutoff in the right direction
      if(pos.or.neg== 1){
        cor.genes=names(cor.data)[cor.data>cor.cutoff]
        cordata=cordata[intersect(row.names(cordata),cor.genes),]
      }
      if(pos.or.neg== 2){
        cor.genes=names(cor.data)[cor.data<(cor.cutoff*-1)]
        cordata=cordata[intersect(row.names(cordata),cor.genes),]
      }
      if(pos.or.neg== 3){
        cor.genes=names(cor.data)[abs(cor.data)>cor.cutoff]
        cordata=cordata[intersect(row.names(cordata),cor.genes),]
      }
      
      
      hmdata = cordata[order(cor.data[row.names(cordata)]),]
      hmdata=t(scale(t(hmdata)))
    
      mylmat = rbind(c(4,2),c(3,1))
      mylwid = c(1.5,5)
      mylhei = c(2,9)
      
      heatmap.2(hmdata,trace="none",col=RdYlBu(100)[100:1], scale="none",
                dendrogram = "none",Rowv=F,Colv=F,
                cexRow = .75, na.color="grey",
                labRow = annot[row.names(hmdata),"symbol"],
                labCol = c("AF1","AF2","AF3","AF4","AF5","IF1","IF2","LF1","LF2","LF3"),
                key = T, lmat=mylmat, lwid=mylwid, lhei=mylhei)
      
    })
}


shinyApp(ui = ui, server = server, options)
