##Run a specific figure shiny app
figure.number = 1

list.of.packages <- c("shiny")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0){
  install.packages('shiny')
}
library(shiny)

if(figure.number == 1){
  ##Run the line plots of liver lactate levels
  runGitHub("https://raw.githubusercontent.com/johncsantiago/Lactate-Correlation-Manuscript/master/Shiny/LactateLinePlot/app.R",repo = "johncsantiago/Lactate-Correlation-Manuscript/", subdir = "/Shiny/LactateLinePlot/")
}

if(figure.number == 2){
  ##Run the heatmap of lactate correlating genes
  runGitHub("https://raw.githubusercontent.com/johncsantiago/Lactate-Correlation-Manuscript/master/Shiny/LactateCorHeatmap/app.R", repo = "johncsantiago/Lactate-Correlation-Manuscript/", subdir = "/Shiny/LactateCorHeatmap/")
}


cpm.cutoff = 20
cor.cutoff = .8
sig.cutoff = .05
pos.or.neg = 1

##trim for genes that meet cpm.cutoff
cpm.genes=apply(cpm.0H,1,max)
cpm.genes=names(cpm.genes[cpm.genes>cpm.cutoff])
cordata=cpm.0H[cpm.genes,]

##trim for genes that meet sig.cutoff
sig.genes=row.names(cor.p)[cor.p<sig.cutoff]
cordata=cordata[intersect(row.names(cordata),sig.genes),]

##trim for genes that meet the cor.cutoff in the right direction
if(pos.or.neg== 1){
  cor.genes=row.names(cor.data)[cor.data>cor.cutoff]
  cordata=cordata[intersect(row.names(cordata),cor.genes),]
}
if(pos.or.neg== 2){
  cor.genes=row.names(cor.data)[cor.data<(cor.cutoff*-1)]
  cordata=cordata[intersect(row.names(cordata),cor.genes),]
}
if(pos.or.neg== 3){
  cor.genes=row.names(cor.data)[abs(cor.data)>cor.cutoff]
  cordata=cordata[intersect(row.names(cordata),cor.genes),]
}

