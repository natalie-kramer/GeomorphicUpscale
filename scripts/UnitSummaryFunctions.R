
#This script takes the OUtput from GUT and summarizes responses by Unit

GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"
#outdir=GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Analysis\\Upscaling"

unitsummary=function(GUTdir,tier=2, response="HSI", transition=T){ #I need to add capability of summarizing layers with or without transition.

  #list.files(GUTdir)
  
 #summarizes the tier2 response
  if(tier==2){  
    T2=read.csv(paste(GUTdir,list.files(GUTdir)[3], sep="\\"))#I need to generalize this to search the file structure for matching names.
      if(response=="HSI"){
        T2Units=read.csv(paste(GUTdir,list.files(GUTdir)[5], sep="\\"), stringsAsFactors=F) #hsi steelhead
        T2Units$SuitArea=as.numeric(T2Units$sthdSuitArea)
        T2Units$No.Fish=as.numeric(T2Units$sthdNo.Redd)
      }
      if(response=="NREI"){
        T2Units=read.csv(paste(GUTdir,list.files(GUTdir)[7], sep="\\")) #nrei
      }
    visitlist=levels(as.factor(T2Units$visit))
    for(i in 1:length(visitlist)){
      subdata1=filter(T2, visit==visitlist[i])%>%
        mutate(UnitForm=Unit)
      subdata=filter(T2Units, visit==visitlist[i])%>%
        full_join(subdata1, by="UnitForm")%>%
        group_by(UnitForm)%>%
        summarize(percArea=max(percArea,  na.rm=T),percHab=sum(SuitArea,  na.rm=T)/max(totArea,  na.rm=T)*100, 
                  Densityhab=sum(No.Fish, na.rm=T)/sum(SuitArea, na.rm=T), Densitybf=sum(No.Fish,na.rm=T)/max(totArea, na.rm=T))
      subdata$visit=as.numeric(visitlist[i])
      if(i==1){data=subdata}else{data=rbind(data,subdata)}
    }
    names(data)[1]=c("Unit")
    }
  
  #summarizes the tier 3 response
  if(tier==3){
  T3=read.csv(paste(GUTdir,list.files(GUTdir)[4], sep="\\"))
     if(response=="HSI"){
       T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[6], sep="\\")) #hsi steelhead
       T3Units$visit=T3Units$VisitID
       #T3Units$SuitArea=T3Units$sthdSuitArea
       #T3Units$No.Fish=T3Units$sthdNo.Redd
     }
       if(response=="NREI"){
         T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[8], sep="\\")) #nrei
       }
  
  visitlist=levels(as.factor(T3Units$visit))
  for(i in 1:length(visitlist)){
    #print(visitlist[i])
    subdata1=filter(T3, visit==visitlist[i])%>%
      mutate(GU=Unit)
    subdata=filter(T3Units, visit==visitlist[i])%>%
      full_join(subdata1, by="GU")%>%
      group_by(GU)%>%
      summarize(percArea=max(percArea), percHab=sum(SuitArea)/max(totArea)*100, 
                Densityhab=sum(No.Fish)/sum(SuitArea), Densitybf=sum(No.Fish)/max(totArea))
    #if(length(which(subdata$Densityhab=="NaN"))>0){subdata[which(subdata$Densityhab=="NaN"),]$Densityhab=0} #makes any densities divided by zero habitat area equal to zero
    #if(length(which(is.na(subdata$GU)))>0){subdata=subdata[-which(is.na(subdata$GU)),]} #eliminates summaries from undefined GUs if they exist
    subdata$visit=as.numeric(visitlist[i])
    if(i==1){data=subdata}else{data=rbind(data,subdata)}
  }
  names(data)[1]=c("Unit")
  }
  
  return(data)
}
  
 
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








