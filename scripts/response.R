
#This script takes the OUtput from GUT and summarizes responses by Unit

###Variables###########################
##GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"
##selections: input table that has columns identifying the riverstyle type/condition as well as another column or columns that
##uniquely identify specific sites. Basically the output from RSselection sourced from "E:\\GitHub\\GeomorphicUpscale\\Scripts\\RSselection.R"
##model="NREI", "HSI"
##responsevar: ("No.Fish", "Hab", "Density", "MedModelVal") No.Fish is the count of fish within each unit type, Hab will give the percent of the unit that contains suitable habitat,
##density will return the # of fish per unit area, and MedModVal will return the average of the Median values of each unit area produced by the response model.
##ROI: (bf, me, hab) specifies region of interest to gather density estimates from, bankful (bf) area, modelling extent (me) or only within suitable habitat (hab)
#areas? default is bf.
##poolby: ("RS", "RScond", "RS", "none")
#######################################


####
#response=function(GUTdir, selections, OUTdir, layer="", 
#                 model="", ROI="", responsevar="", poolby="") {     #, selectionfilepath=NA, idcolname="Visit", RScolname="RS"){ #I need to add capability of summarizing layers with or without transition.

library(dplyr)
library(tidyr)


OUTdir=paste(PROJdir,"Outputs", sep="\\")
if (file.exists(OUTdir)==F){dir.create(OUTdir)}
if (file.exists(paste(OUTdir,layer, sep="\\"))==F){dir.create(paste(OUTdir,layer, sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Selection",sep="\\"))==F){dir.create(paste(OUTdir,layer,"Selection", sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Selection", model, sep="\\"))==F){dir.create(paste(OUTdir,layer, "Selection", model, sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Selection" , model, responsevar, sep="\\"))==F){dir.create(paste(OUTdir,layer, "Selection", model, responsevar, sep="\\"))}

if(responsevar=="MedModelVal"){
  if (file.exists(paste(OUTdir,layer, "Selection",  model, responsevar,sep="\\"))==F){
    dir.create(paste(OUTdir,layer, "Selection", model, responsevar, sep="\\"))}
  OUTfolder=paste(OUTdir,layer,"Selection", model, responsevar,sep="\\")}else {
    if (file.exists(paste(OUTdir,layer, "Selection",  model, responsevar, ROI ,sep="\\"))==F){
      dir.create(paste(OUTdir,layer, "Selection", model, responsevar,ROI, sep="\\"))}
    OUTfolder=paste(OUTdir,layer,"Selection", model, responsevar, ROI ,sep="\\")}

GUTdir=paste(DATAdir,"\\GUTMetrics\\GUT2.1Run01" , sep="")
#List GUToutput files corresponding to Layer
GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]

#Read in Unit Data
unitmetrics=read.csv(paste(GUTdir,GUToutputlist[grep("unit", GUToutputlist)],sep="\\"),stringsAsFactors=F)

#Reads in Fish Response Data  
responsemetrics=read.csv(paste(GUTdir,GUToutputlist[grep(paste("UnitID_",model, sep=""), GUToutputlist)],sep="\\"), stringsAsFactors=F)

sumresponse=responsemetrics%>%
  group_by(visit)%>%
  summarize(Capacity_M=sum(No.Fish, na.rm=T), 
            MedModelVal_M=sum(AreainDelft*MedModelVal, na.rm=T)/sum(AreainDelft, na.rm=T),
            No.GU_M=length(na.omit(UnitID)),
            bfArea=sum(Area, na.rm=T),
            hydroArea=sum(AreainDelft, na.rm=T),
            habArea=sum(SuitArea, na.rm=T))

write.csv(sumresponse, paste(GUTdir,"\\" , "site" , model, "response_",  layer, ".csv", sep=""))


#sumresponse2=responsemetrics%>%
#  group_by(visit, Unit)%>%
#  summarize(Capacity_M=sum(No.Fish, na.rm=T), 
#            MedModelVal_M=sum(AreainDelft*MedModelVal, na.rm=T)/sum(AreainDelft, na.rm=T),
#            No.GU_M=length(na.omit(UnitID)),
#            bfArea=sum(Area, na.rm=T),
#            hydroArea=sum(AreainDelft, na.rm=T),
 #           habArea=sum(SuitArea, na.rm=T))


#checking areas...
#sitemetrics=read.csv(paste(GUTdir,GUToutputlist[grep("siteGUTmetrics", GUToutputlist)],sep="\\"),stringsAsFactors=F)

#responsecompare=sumresponse2%>%
#  left_join(unitmetrics, by=c("visit", "Unit"))%>%
#  group_by(visit)%>%
#  summarize(NREIArea=sum(bfArea), GUArea=sum(totArea), NREIhydroarea=sum(hydroArea), NREIhabarea=sum(habArea))%>%
#  left_join(sitemetrics, by=c("visit"="VisitID"))

#responsecompare[which(abs(responsecompare$bfArea-responsecompare$totArea)>10),]$visit
#plot(responsecompare$totArea, responsecompare$bfArea)

#cleans up headers to be consistent with unitmetrics and across Tiers
if(layer=="Tier2_InChannel_Transition"|layer=="Tier2_InChannel"){
  unitcol= which(names(responsemetrics)=="UnitForm")
}

if(layer=="Tier3_InChannel"){
  unitcol= which(names(responsemetrics)=="GU")
}

#renames so that col header for unit name is always 'Unit'
responsemetrics$Unit=as.factor(as.character(responsemetrics[,unitcol]))
unitmetrics$Unit=as.factor(as.character(unitmetrics$Unit))

#Selects for only response type we utilize
response=select(responsemetrics,visit,Unit,Area,AreainDelft, SuitArea,No.Fish, MedModelVal)

visitlist=levels(as.factor(selections$visit))


#selects just response type and ROI identified
for(i in 1:length(visitlist)){
  area=filter(unitmetrics, visit==visitlist[i])%>%
    select(Unit, totArea)
  subresponse=filter(response, visit==visitlist[i])%>%
    right_join(area, by="Unit")%>%
    filter(!is.na(Unit))%>%
    group_by(Unit)
  
  if(responsevar=="Density"& ROI=="bf"){
    subresponse=summarize(subresponse, var=sum(No.Fish, na.rm=T)/(max(totArea, na.rm=T)), visit=max(visit))
  }
  if(responsevar=="Density"& ROI=="hydro"){
    #subresponse=summarize(subresponse, var=sum(No.Fish, na.rm=T)/(sum(Area, na.rm=T)), visit=max(visit))
    print("Cannot generate estimates of density within hydro extent at this time, pick different ROI")
  }
  if(responsevar=="Density"& ROI=="hab"){
    subresponse=summarize(subresponse, var=sum(No.Fish, na.rm=T)/(sum(SuitArea, na.rm=T)), visit=max(visit))
  }
  if(responsevar=="No.Fish"){
    subresponse=summarize(subresponse, var=sum(No.Fish, na.rm=T), visit=max(visit))
  }
  if(responsevar=="Hab"& ROI=="bf"){
    subresponse=summarize(subresponse, var=sum(SuitArea, na.rm=T)/(sum(totArea, na.rm=T)), visit=max(visit))
  }
  if(responsevar=="Hab"& ROI=="hydro"){
    #subresponse=summarize(subresponse, var=sum(SuitArea, na.rm=T)/(sum(Area, na.rm=T)), visit=max(visit))
    print("Cannot generate estimates of hab within hydro extent at this time, pick different ROI")
  }
  if(responsevar=="MedModelVal"){
    subresponse=summarize(subresponse, var=sum(AreainDelft*MedModelVal, na.rm=T)/sum(AreainDelft), visit=max(visit))
  }
  if(i==1){myresponse=subresponse}else{myresponse=rbind(myresponse,subresponse)}
  
}



if(poolby=="none"){
  myresponse2=myresponse%>%
    filter(!is.na(Unit))%>%
    group_by(Unit)%>%
    summarize(avg=mean(var, na.rm=T), 
              sd=sd(var, na.rm=T),
              med=median(var, na.rm=T), 
              min=min(var, na.rm=T) ,
              max=max(var, na.rm=T),
              n=length(na.omit(var)))%>%
    mutate(RScond=NA, Condition=NA, RS=NA)
}

if(poolby=="RScond"){
  RSlist=levels(selections$RScond) #create list of RS 
  for(i in 1:length(RSlist)){
    subdata1=filter(selections, RScond==RSlist[i])%>%
      select(RScond,visit)%>%
      left_join(myresponse, by="visit")%>%filter(!is.na(Unit))%>%
      group_by(Unit)%>%
      summarize(avg=mean(var, na.rm=T), 
                sd=sd(var, na.rm=T),
                med=median(var, na.rm=T), 
                min=min(var, na.rm=T) ,
                max=max(var, na.rm=T),
                n=length(na.omit(var)))%>%
      mutate(RScond=as.character(RSlist[i]))%>%
      extract(RScond, into = c("RS"), "(.[:upper:]*)", remove=F)%>%
      extract(RScond, into = c("Condition"), "([:lower:].*)", remove=F)
    
    if(i==1){myresponse2=subdata1}else{myresponse2=rbind(myresponse2,subdata1)}
  }
}

if(poolby=="RS"){
  selections1=selections%>%
    extract(RScond, into = c("RS"), "(.[:upper:]*)", remove=F)
  RSlist=levels(as.factor(selections1$RS)) #create list of RS 
  for(i in 1:length(RSlist)){
    subdata1=filter(selections1, RS==RSlist[i])%>%
      select(RS,visit)%>%
      distinct()%>%
      left_join(myresponse, by="visit")%>%
      filter(!is.na(Unit))%>%
      group_by(Unit)%>%
      summarize(avg=mean(var, na.rm=T), 
                sd=sd(var, na.rm=T),
                med=median(var, na.rm=T), 
                min=min(var, na.rm=T) ,
                max=max(var, na.rm=T),
                n=length(na.omit(var)))%>%
      mutate(RScond=NA, Condition=NA, RS=as.character(RSlist[i]))
    if(i==1){myresponse2=subdata1}else{myresponse2=rbind(myresponse2,subdata1)}
  }
}

#spreads table so that unit types are converted to columns and RSconds are rows.   
slim=myresponse2%>%
  group_by(RS)%>%
  select(-sd,-med,-min,-max,-n)%>%
  spread(key="Unit", value=avg)

responses=list(response_stats=myresponse2, response_est=slim)

print(paste("layer = ", layer))
print(paste("model = ", model))
print(paste("ROI = ", ROI))
print(paste("response = ", responsevar))
print(paste("poolby = ", poolby))  
print(responses)

write.csv(slim, paste(OUTfolder, "\\", "responseby", poolby, "_est.csv", sep=""), row.names=F)
write.csv(myresponse2, paste(OUTfolder, "\\", "responseby", poolby, "_stats.csv", sep=""), row.names=F)
print(paste("files successfully written to: ", OUTfolder,  sep=""))


if(makeplot==T){
  #responsechart=function(mydata=response_est,layer="Tier2_InChannel_Transition",model="NREI",
  #                       responsevar="Density", ROI="bf", poolby="RS", OUTdir=F, plottype=".tiff"){
  library(ggplot2)
  mydata=slim

  #Read in and manipulate data for plotting
  cols=length(names(mydata))  
  
  print(paste("response=" , responsevar))
  mydata1=gather(mydata, key="Unit", value=response, 4:(cols))
  #names(mydata1)[which(names(mydata1)=='response')]=responsevar
  
  
  myplot <- ggplot(mydata1) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  
  
  
  if(poolby=="RScond"){
    #sets factor order to increase from poor to intact
    mydata1$Condition=factor(mydata1$Condition, levels=c("poor", "mod", "good","intact"))
    mycolors=c(poor="red", mod="yellow", good="green", intact="purple")
    
    
    myplot <- ggplot(mydata1) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    plot1= myplot + geom_point(aes(x=Unit, y=response, col=Condition, shape=RS)) +
      scale_fill_manual(values = mycolors)
    
    plot2=myplot+geom_point(aes(x=RS, y=response, col=Condition)) +
      scale_fill_manual(values = mycolors)+
      #scale_shape_manual("", values=c(17,17,16,16)
      facet_grid( ~ Unit) +
      facet_wrap( ~ Unit, scales='fixed')
    
    print(plot2)
    if(is.na(OUTdir)==F){
      
      if(plottype==".pdf"){
        ggsave(paste(OUTfolder, "\\","responseby", poolby,  "_facetbyUnit.pdf", sep=""), plot=plot2, width = 8, height = 6)}
      
      if(plottype==".png"){
        ggsave(paste(OUTfolder, "\\","responseby",  poolby,  "_facetbyUnit.png", sep=""), plot=plot2, width = 8, height = 6)}

      if(plottype==".tiff"){
        ggsave(paste(OUTfolder, "\\","responseby", poolby, "_facetbyUnit.tiff", sep=""), plot=plot2, width = 8, height = 6)}
    }
  }
  
  if(poolby=="RS"){
    plot1= myplot + geom_point(aes(x=Unit, y=response, col=RS))
  }
  
  if(poolby=="none"){    
    plot1= myplot + geom_point(aes(x=Unit, y=response))
  }
  
  
  print(plot1)
  
  
  
  if(is.na(OUTdir)==F){
    
    if(plottype==".pdf"){
      ggsave(paste(OUTfolder, "\\","responseby", poolby,  ".pdf", sep=""), plot=plot1, width = 8, height = 6)}

    if(plottype==".png"){
      ggsave(paste(OUTfolder, "\\","responseby", poolby,  ".png", sep=""), plot=plot1, width = 8, height = 6)}

    if(plottype==".tiff"){
      ggsave(paste(OUTfolder, "\\","responseby",  poolby,  ".tiff", sep=""), plot=plot1, width = 8, height = 6)}
  }
  
}



keepvars=c("criteria", "selections", "PROJdir","plottype", "DATAdir", "makeplot", "network", "layer", "model", "ROI", "responsevar", "poolby")



    #  }
####Example Usage######################
#######################################
#selections=read.csv("E:\\GitHub\\GeomorphicUpscale\\AsotinExampleData\\Inputs\\AsotinSelections.csv")
#GUTdir="E:\\GitHub\\GeomorphicUpscale\\Database\\GUTMetrics\\GUT2.1Run01"
#OUTdir="E:\\GitHub\\GeomorphicUpscale\\AsotinExampleData\\Outputs"
#
#source(
#a=response(GUTdir, selections, layer="Tier3_InChannel",
#                  model="NREI", ROI="bf", responsevar="Hab", poolby="none")
#responsechart(a$response_est, responsevar="Density", poolby="RS", ROI="bf", OUTdir=OUTdir, type=".tiff")
#
#
#######################################
#######################################







