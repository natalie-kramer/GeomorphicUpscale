
#This script takes the OUtput from GUT and summarizes responses by Unit

GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"
#outdir=GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Analysis\\Upscaling"
#myselections is a vector of visits to summarize.
selectionfilepath="E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotinselections.csv"



unitsummary=function(GUTdir,layer="Tier2_InChannel_Transition", response="none") {     #, selectionfilepath=NA, idcolname="Visit", RScolname="RS"){ #I need to add capability of summarizing layers with or without transition.
  
  library(dplyr)
  
  #List GUToutput files corresponding to Layer
  GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]
  
  #Read in Unit Data
  unitmetrics=read.csv(paste(GUTdir,GUToutputlist[grep("unit", GUToutputlist)],sep="\\"),stringsAsFactors=F)
  
  
  #Read in selection list if it exists
#  if(is.na(selectionfilepath)){
    visitlist=levels(as.factor(unitmetrics$visit))  #} else {
   #   selections=read.csv(selectionfilepath)  
   #   RScol=which(colnames(selections)==RScolname)
   #   idcol=which(colnames(selections)==idcolname)
   #   visitlist=levels(as.factor(as.character(selections[,idcol])))}
  
  #compiles just output of percAreas if response is set to none
  if (response=="none"){
    for(i in 1:length(visitlist)){
      subdata=filter(unitmetrics, visit==visitlist[i])%>%
        select(Unit, percArea, visit)
      if(i==1){data=subdata}else{data=rbind(data,subdata)}
    }
  }
  
  
  #Summarizes response data as well if response is indicated as "HSI" or "NREI"
  if (response!="none"){
    
  #Reads in Fish Response Data  
  responsemetrics=read.csv(paste(GUTdir,GUToutputlist[grep(response, GUToutputlist)],sep="\\"), stringsAsFactors=F)
  
  #and cleans up headers to be consistent
  if(layer=="Tier2_InChannel_Transition"|layer=="Tier2_InChannel"){
    unitcol= which(names(responsemetrics)=="UnitForm")}
  if(layer=="Tier3_InChannel"){
    unitcol= which(names(responsemetrics)=="GU")}

  
  
  #renames so that col header for unit name is always 'Unit'
    responsemetrics$Unit=as.factor(as.character(responsemetrics[,unitcol]))
  
    
    #Something seems to be off about the HSI outuput from GUT.  For now, it will only run NREI responses
    #This simply renames HSI header output to be more consistent with header names. If GUT output naming convenions change this will break.
    if(response=="HSI" & layer=="Tier2_InChannel_Transition"){
      responsemetrics$SuitArea=as.numeric(responsemetrics$sthdSuitArea)
      responsemetrics$No.Fish=as.numeric(responsemetrics$sthdNo.Redd)
    }
    
     #summarizes the response
  for(i in 1:length(visitlist)){
      subdata0=filter(unitmetrics, visit==visitlist[i])
      subdata1=filter(responsemetrics, visit==visitlist[i])%>%
        full_join(subdata0, by="Unit")%>%
        #select(Unit, percArea, totArea, SuitArea, No.Fish)
        group_by(Unit)%>%
        summarize(percArea=max(percArea,  na.rm=T),percHab=sum(SuitArea,  na.rm=T)/max(totArea,  na.rm=T)*100, 
                  Densityhab=sum(No.Fish, na.rm=T)/sum(SuitArea, na.rm=T), Densitybf=sum(No.Fish,na.rm=T)/max(totArea, na.rm=T), 
                  No.Fish_avg=mean(No.Fish, na.rm=T),No.Fish_sd=sd(No.Fish, na.rm=T))
      subdata1$visit=as.numeric(visitlist[i])
      if(i==1){data=subdata1}else{data=rbind(data,subdata1)}
  }
    
  }

    return(data)
}
 



a=unitsummary(GUTdir, layer="Tier2_InChannel_Transition", response="none")
b=unitsummary(GUTdir, layer="Tier2_InChannel_Transition", response="NREI")

d=unitsummary(GUTdir, layer="Tier3_InChannel", response="none")
e=unitsummary(GUTdir, layer="Tier3_InChannel", response="NREI")


f=unitsummary(GUTdir, layer="Tier3_InChannel", response="HSI")
c=unitsummary(GUTdir, layer="Tier2_InChannel_Transition", response="HSI")


unitsummary(GUTdir, layer="Tier2_InChannel_Transition", response="none", selectionfile=selections)

  
  
#   #summarizes the tier 3 response
#   if(tier==3){
#  T3=read.csv(paste(GUTdir,list.files(GUTdir)[4], sep="\\"))
#      if(response=="HSI"){
#        T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[6], sep="\\")) #hsi steelhead
#        T3Units$visit=T3Units$VisitID
#        #T3Units$SuitArea=T3Units$sthdSuitArea
#        #T3Units$No.Fish=T3Units$sthdNo.Redd
#      }
#        if(response=="NREI"){
#          T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[8], sep="\\")) #nrei
#        }
#   
#   visitlist=levels(as.factor(T3Units$visit))
#   for(i in 1:length(visitlist)){
#     #print(visitlist[i])
#     subdata1=filter(T3, visit==visitlist[i])%>%
#       mutate(GU=Unit)
#     subdata=filter(T3Units, visit==visitlist[i])%>%
#       full_join(subdata1, by="GU")%>%
#       group_by(GU)%>%
#       summarize(percArea=max(percArea), percHab=sum(SuitArea)/max(totArea)*100, 
#                 Densityhab=sum(No.Fish)/sum(SuitArea), Densitybf=sum(No.Fish)/max(totArea))
#     #if(length(which(subdata$Densityhab=="NaN"))>0){subdata[which(subdata$Densityhab=="NaN"),]$Densityhab=0} #makes any densities divided by zero habitat area equal to zero
#     #if(length(which(is.na(subdata$GU)))>0){subdata=subdata[-which(is.na(subdata$GU)),]} #eliminates summaries from undefined GUs if they exist
#     subdata$visit=as.numeric(visitlist[i])
#     if(i==1){data=subdata}else{data=rbind(data,subdata)}
#   }
#   names(data)[1]=c("Unit")
#   }
#   
#   return(data)
# }
#   
 
#list.files(GUTdir)
#unitsummary(GUTdir, tier=2, response="HSI", 
#unitsummary(GUTdir, tier=2, response="NREI"
#unitsummary(GUTdir, tier=3, response="HSI"
#unitsummary(GUTdir, tier=3, response="NREI"

densitybfsummary=function(mydata){
  mydata=mydata%>% 
    group_by(Unit)%>%
    summarize(avg=mean(Densitybf, na.rm=T) 
              , sd=sd(Densitybf, na.rm=T)
              , median=median(Densitybf, na.rm=T)
              , max=max(Densitybf, na.rm=T)
              , min=min(Densitybf, na.rm=T)
              , n=length(na.omit(Densitybf)))
  return(mydata)
}

densityhabsummary=function(mydata){
  mydata=mydata%>% 
    group_by(Unit)%>%
    summarize(avg=mean(Densityhab, na.rm=T) 
              , sd=sd(Densityhab, na.rm=T)
              , median=median(Densityhab, na.rm=T)
              , max=max(Densityhab, na.rm=T)
              , min=min(Densityhab, na.rm=T)
              , n=length(na.omit(Densityhab)))
  return(mydata)
}
percAreasummary=function(mydata){
  mydata=mydata%>% 
    group_by(Unit)%>%
    summarize(avg=mean(percArea, na.rm=T) 
              , sd=sd(percArea, na.rm=T)
              , median=median(percArea, na.rm=T)
              , max=max(percArea, na.rm=T)
              , min=min(percArea, na.rm=T)
              , n=length(na.omit(percArea)))
  return(mydata)
}


percHabsummary=function(mydata){
  mydata=mydata%>% 
    group_by(Unit)%>%
    summarize(avg=mean(percHab, na.rm=T) 
              , sd=sd(percHab, na.rm=T)
              , median=median(percHab, na.rm=T)
              , max=max(percHab, na.rm=T)
              , min=min(percHab, na.rm=T)
              , n=length(na.omit(percHab)))
  return(mydata)
}


####Extra Code I might need to do something with

#Estimated Density by Unit
#riverdata$visit=as.numeric(riverdata$VisitID)
#fishdata$visit=as.numeric(fishdata$VisitID)
#visitdata$visit=as.numeric(visitdata$VisitID)
#champdata$visit=as.numeric(champdata$VisitID)


#data=data%>%
#  full_join(riverdata, by="visit")%>%
#  full_join(visitdata, by="visit")%>%
#  #full_join(champdata, by="SiteName")%>%
#  filter(is.na(Unit)==F)


#CB=densitybfsummary(data%>%filter(RS_AsotinAnalogue=="confined valley BD"))
#CF=densitybfsummary(data%>%filter(RS_AsotinAnalogue=="confined valley FP"))
#FC=densitybfsummary(data%>%filter(RS_AsotinAnalogue=="fan controlled"))
#PC=densitybfsummary(data%>%filter(RS_AsotinAnalogue=="planform controlled"))
#WA=densitybfsummary(data%>%filter(RS_AsotinAnalogue=="wandering"))
#MD=densitybfsummary(data%>%filter(is.na(RS_AsotinAnalogue)))

#CB$RS="CB"
#CF$RS="CF"
#FC$RS="FC"
#PC$RS="PC"
#WA$RS="WA"
#MD$RS="MD"

#densitysum=rbind(CB, CF,FC,PC,WA)


#write.csv(densitysum, "E:/Box Sync/ET_AL/Projects/USA/ISEMP/GeomorphicUnits/Analyses/Upscaling/T3DensityGU_HSIsthd_AsotinRSsummary.csv")








