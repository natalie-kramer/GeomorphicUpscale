#Estimates Empirical assemblages of geomorphic units as percent of bankful area of each unit type for
#reach selections from RSselection.R

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Nov 27th 2018

##Function
assemblage=function(GUTdir,layer="Tier2_InChannel_Transition", selections=myselections){ #I need to add capability of summarizing layers with or without transition.
  
  library(dplyr)
  
  #List GUToutput files corresponding to Layer
  GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]
  
  #Read in Unit Data
  unitmetrics=read.csv(paste(GUTdir,GUToutputlist[grep("unit", GUToutputlist)],sep="\\"),stringsAsFactors=F)
  visitlist=levels(as.factor(unitmetrics$visit))
  #compiles just output of percAreas if response is set to none
    for(i in 1:length(visitlist)){
      subdata=filter(unitmetrics, visit==visitlist[i])%>%
        select(Unit, percArea, visit)
      if(i==1){unitdata=subdata}else{unitdata=rbind(unitdata,subdata)}
    }
  
  #print(head(unitdata))
  
#RScol=which(colnames(selections)==RScolname)
#idcol=which(colnames(selections)==idcolname)

#RSdata=rbind(selections[,RScol],selections[,idcol])
#names(RSdata)=c(RS,Visit)

RSlist=levels(selections$RS) #create list of RS 
 # print("RSlist")
#  print(RSlist)
  
  for(i in 1:length(RSlist)){
    subdata1=filter(selections, RS==RSlist[i])%>%
      select(RS,visit)%>%
      #rename(visit=Visit)%>%
      left_join(unitdata, by="visit")%>%
      group_by(Unit)%>%
      summarize(avg=mean(percArea, na.rm=T), 
                sd=sd(percArea, na.rm=T),
                med=median(percArea, na.rm=T), 
                min=min(percArea, na.rm=T) ,
                max=max(percArea, na.rm=T),
                n=length(na.omit(percArea)))
    subdata1$RS=RSlist[i]
    if(i==1){assemblage=subdata1}else{assemblage=rbind(assemblage,subdata1)}
  }
  
  return(assemblage)

}

###Variables
##GUTdir: The directory where the GUT metrics output files exist. This script uses the GUTunit
##selections: input csv that has columns identifying the riverstyle type/condition as well as another column or columns that
##uniquely identify specific sites. Basically the output from RSselection sourced from "E:\\GitHub\\GeomorphicUpscale\\Scripts\\RSselection.R"
######

##Example Usage
#GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"
#myselections=read.csv("E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotinselections.csv")
#
#a=assemblage(GUTdir, layer="Tier2_InChannel_Transition", selections=myselections)
#write.csv(a,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier2_assemblage.csv", row.names=F)
#
#
#b=assemblage(GUTdir, layer="Tier3_InChannel", selections=myselections)
#write.csv(b,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier3_assemblage.csv", row.names=F)


  