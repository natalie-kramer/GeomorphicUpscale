setwd("E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Analyses\\ReachEDA")


reachdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\ReachMetrics"
GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"


list.files(reachdir)
champdata=read.csv(paste(reachdir,list.files(reachdir)[3], sep="\\"))
fishdata=read.csv(paste(reachdir,list.files(reachdir)[4] , sep="\\")) 
riverdata=read.csv(paste(reachdir,  list.files(reachdir)[5], sep="\\"))
visitdata=read.csv(paste(reachdir, list.files(reachdir)[6], sep="\\"))
confinement=read.csv(paste(reachdir, list.files(reachdir)[1], sep="\\"))

#reads in summary by reach of different geomorphic units for each visit in the database
list.files(GUTdir)
T2=read.csv(paste(GUTdir,list.files(GUTdir)[3], sep="\\"))
T3=read.csv(paste(GUTdir,list.files(GUTdir)[4], sep="\\"))

#T2 and T3 for HSI
T2Units=read.csv(paste(GUTdir,list.files(GUTdir)[5], sep="\\")) #hsi steelhead
T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[6], sep="\\")) #hsi steelhead
T3Units$visit=T3Units$VisitID

#T2 and T3 for running NREI
T2Units=read.csv(paste(GUTdir,list.files(GUTdir)[7], sep="\\")) #nrei
T3Units=read.csv(paste(GUTdir,list.files(GUTdir)[8], sep="\\")) #nrei

library(dplyr)

#T2 unit summary percent suitable and density
visitlist=levels(as.factor(T2Units$visit))
for(i in 1:length(visitlist)){
  subdata1=filter(T2, visit==visitlist[i])%>%
    mutate(UnitForm=Unit)
  subdata=filter(T2Units, visit==visitlist[i])%>%
    full_join(subdata1, by="UnitForm")%>%
    group_by(UnitForm)%>%
    summarize(percArea=max(percArea),percHab=sum(SuitArea)/max(totArea)*100, 
              Densityhab=sum(No.Fish)/sum(SuitArea), Densitybf=sum(No.Fish)/max(totArea))
  subdata$visit=as.numeric(visitlist[i])
  if(i==1){data=subdata}else{data=rbind(data,subdata)}
}
names(data)[1]=c("Unit")


#T3 unit summary percent suitable and density
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


champdata2=champdata%>%
  full_join(confinement, by="SiteName")
riverdata$visit=as.numeric(riverdata$VisitID)
#fishdata$visit=as.numeric(fishdata$VisitID)
visitdata$visit=as.numeric(visitdata$VisitID)
champdata2$visit=as.numeric(champdata2$VisitID)



data=data%>%
  full_join(riverdata, by="visit")%>%
  full_join(visitdata, by="visit")%>%
  full_join(champdata2, by="visit")%>%
  filter(is.na(Unit)==F)


#Subsets and plots data by attribute
myplotfunc=function(unit){

data0=data[which(data$Unit==unit),]
  
data1=data0%>%
  #filter(Unit=="Pool")%>%
  transmute(percArea, percHab, Densityhab, Densitybf, visit, Grad.x, Sin, Confinement, Bedform, Threads, LWfreq, modeleld.confinement)%>%
  mutate(Gradient2=NA, Sinuosity2=NA, LargeWood2=NA, Confinement2=NA, Bedform2=NA, Threads2=NA) 
         
for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$Grad.x)){data1[i,]$Gradient2="NA"}else{
  if(data1[i,]$Grad.x<1){data1[i,]$Gradient2="1.Low"}
  if(data1[i,]$Grad.x>1 & data1[i,]$Grad.x<2){data1[i,]$Gradient2="2.Moderate"}
  if(data1[i,]$Grad.x>2 & data1[i,]$Grad.x<3){data1[i,]$Gradient2="3.High"}
  if(data1[i,]$Grad.x>3){data1[i,]$Gradient2="4.VeryHigh"}
  }
  #print(i)
  #i=i+1
}


for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$Sin)){data1[i,]$Sinuosity2="NA"}else{
    if(data1[i,]$Sin<1.06){data1[i,]$Sinuosity2="1.Straight"}
    if(data1[i,]$Sin>1.06 & data1[i,]$Sin<1.3){data1[i,]$Sinuosity2="2.Low sinuous"}
    if(data1[i,]$Sin>1.3 & data1[i,]$Sin<1.5){data1[i,]$Sinuosity2="3.Mod Sinuous"}
    if(data1[i,]$Sin>1.5 & data1[i,]$Sin<1.8){data1[i,]$Sinuosity2="4.Meandering"}
    if(data1[i,]$Sin>1.8){data1[i,]$Sinuosity2="5.Tortuous"}
  }
  #print(i)
  #i=i+1
}

for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$LWfreq)){data1[i,]$LargeWood2="NA"}else{
    if(data1[i,]$LWfreq==0){data1[i,]$LargeWood2="1.None"}
    if(data1[i,]$LWfreq>0 & data1[i,]$LWfreq<15){data1[i,]$LargeWood2="2.Low"}
    if(data1[i,]$LWfreq>15 & data1[i,]$LWfreq<50){data1[i,]$LargeWood2="3.Moderate"}
    if(data1[i,]$LWfreq>50){data1[i,]$LargeWood2="4.High"}
  }
  #print(i)
  #i=i+1
}

#for(i in 1:length(data1$visit)){
 # if(is.na(data1[i,]$modeleld.confinement)){data1[i,]$Confinement2="NA"}else{
#    if(data1[i,]$modeleld.confinement<0.1){data1[i,]$Confinement2="1.Unconfined (UCV)"}
##    if(data1[i,]$modeleld.confinement>.1 & data1[i,]$modeleld.confinement<.85){data1[i,]$Confinement2="2.Partly Confined (PCV)"}
#    if(data1[i,]$modeleld.confinement>0.85){data1[i,]$Confinement2="3.Confined (CV)"}
#  }
  #print(i)
  #i=i+1
#

for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$Confinement)){data1[i,]$Confinement2="NA"}else{
    if(data1[i,]$Confinement=="CV"){data1[i,]$Confinement2="1.Confined (CV)"}
    if(data1[i,]$Confinement=="PCV"){data1[i,]$Confinement2="2.Partly Confined (PCV)"}
    if(data1[i,]$Confinement=="UCV"){data1[i,]$Confinement2="3.Unconfined (UCV)"}
  }
  #print(i)
  #i=i+1
}

for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$Threads)){data1[i,]$Threads2="NA"}else{
    if(data1[i,]$Threads=="Single"){data1[i,]$Threads2="1.Single"}
    if(data1[i,]$Threads=="Transitional"){data1[i,]$Threads2="2.Transitional"}
    if(data1[i,]$Threads=="Multi"){data1[i,]$Threads2="3.Multi"}
  }
  #print(i)
  #i=i+1
}

for(i in 1:length(data1$visit)){
  if(is.na(data1[i,]$Bedform)){data1[i,]$Bedform2="NA"}else{
    if(data1[i,]$Bedform=="Plane-Bed"){data1[i,]$Bedform2="1.Plane-Bed"}
    if(data1[i,]$Bedform=="Pool-Riffle"){data1[i,]$Bedform2="2.Pool-Riffle"}
    if(data1[i,]$Bedform=="Step-Pool"){data1[i,]$Bedform2="3.Step-Pool"}
    if(data1[i,]$Bedform=="Rapid"){data1[i,]$Bedform2="4.Rapid"}
    if(data1[i,]$Bedform=="Cascade"){data1[i,]$Bedform2="5.Cascade"}
  }
  #print(i)
  #i=i+1
}



library(tidyverse)
data2=data1[,-c(6:12)]

names(data2) =c("percArea"    , "percHab"     , "Densityhab"  ,"Densitybf"  ,  "visit"     ,  
                "Gradient" ,   "Sinuosity"  , "LargeWood" ,  "Confinement" ,"Bedform"  ,   "Threads")

data3=data2%>%
  gather(key=attribute, value=category, Gradient, Sinuosity, Confinement, Bedform, Threads, LargeWood)

data3=data3[-which(is.na(data3$category)),]
data3=data3[-which(data3$category=="NA"),]


#ata3$category



base=ggplot(data3)+ xlab(NULL)+facet_grid(~attribute, scale="free") + 
  theme(strip.text.x=element_text(angle=0), axis.text.x=element_text(angle=90))#+
  #scale_colour_brewer(palette="Set2")+
  #scale_colour_manual(values=colors)


Myplot=base+geom_boxplot(aes(category, percArea))+ylab(paste("% of Bankfull is ",unit, sep=""))+ geom_jitter(aes(category, percArea), width=0.2, height=0)
#Myplot
                                                       

 


#base+geom_boxplot(aes(category, percHab))+ylab("% of Bankfull Pool Area with Suitable NREI")+ geom_jitter(aes(category, percHab), width=0.2, height=0)
#base+geom_boxplot(aes(category, Densitybf))+ylab("Juvenile Density within Bankfull Pool Area")+ 
#  geom_jitter(aes(category, Densitybf), width=0.2, height=0)+ylim(c(0,2.5))
#base+geom_boxplot(aes(category, Densitybf))+ylab("Redd Density within Bankfull Pool Area")+ 
#  geom_jitter(aes(category, Densitybf), width=0.2, height=0)
#base+geom_boxplot(aes(category, Densityhab))+ylab("Juvenile Density within Suitable Pool Area")+ 
#  geom_jitter(aes(category, Densityhab), width=0.2, height=0)+ylim(c(0,2.5))

pdf(paste("Perc", unit, ".pdf", sep=""), width=8, height=4)
print(Myplot)
dev.off()
}

myplotfunc("Pool")
myplotfunc("Pocket Pool")
myplotfunc("Mid Channel Bar")
myplotfunc("Riffle")
myplotfunc("Glide-Run")

         