library(dplyr)
library(tidyr)

#Create folder structure
OUTdir=paste(PROJdir,"Outputs", sep="\\")
if (file.exists(OUTdir)==F){dir.create(OUTdir)}
if (file.exists(paste(OUTdir,layer, sep="\\"))==F){dir.create(paste(OUTdir,layer, sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Upscale", sep="\\"))==F){dir.create(paste(OUTdir,layer, "Upscale", sep="\\"))}

RESULTdir=paste(OUTdir,layer, "Upscale", model, sep="\\")
if (file.exists(RESULTdir)==F){dir.create(RESULTdir)}
if (file.exists(paste(RESULTdir, upscalevar, sep="\\"))==F){dir.create(paste(RESULTdir, upscalevar, sep="\\"))}

#create subfolders
if(upscalevar=="Capacity"){
  if(file.exists(paste(RESULTdir, upscalevar, ROI, sep="\\"))==F){
  dir.create(paste(RESULTdir, upscalevar, ROI, sep="\\"))}
  OUTfolder=paste(RESULTdir, upscalevar, ROI, poolby, sep="\\")}else{OUTfolder=paste(RESULTdir, upscalevar, poolby, sep="\\")}
  if(file.exists(OUTfolder)==F){dir.create(OUTfolder)}


if(validateselection==F){
   if(is.na(Areacols) == F){
  OUTfolder=paste(OUTfolder, "UserArea", sep="\\")
  if(file.exists(OUTfolder)==F){
    dir.create(OUTfolder)}
   }
  if(is.na(Areacols) == T){
    OUTfolder=paste(OUTfolder, "EstArea", sep="\\")
    if(file.exists(OUTfolder)==F){
      dir.create(OUTfolder)}
  }
}


#Read in estimates of Assemblages and re-arrange
assemblage=read.csv(paste(OUTdir, "\\", layer,"\\" ,"Selection\\GU\\", "\\assemblage_stats.csv", sep=""))
bfgu=assemblage %>%
  #select("RScond","Condition", "RS", "Unit", PercGU="avg")
  rename(PercGU=avg)
bfgu$RScond=as.character(bfgu$RScond)


#Read in response variable by type of upscale defined
if(upscalevar=="Capacity" & ROI=="bf"){ 
 # if(poolby=="RScond"){
    response=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\Density\\bf\\responseby", poolby, "_stats.csv", sep=""))%>%
      rename("bfdensity"=avg, "sd.r"=sd, "n.r"=n)
    }
# if(poolby=="RS"){
#    response=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\Density\\bf\\responsebyRS_stats.csv", sep=""))}
#  if(poolby=="none"){
#    response=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\Density\\bf\\responsebynone_stats.csv", sep=""))}
#}

if(upscalevar=="Capacity" & ROI=="hab"){ 

    response1=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\Density\\hab\\responseby", poolby, "_stats.csv", sep=""))%>%
      rename(habdensity=avg, "sd.r"=sd, "n.r"=n)
    response2=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\Hab\\bf\\responseby", poolby,  "_stats.csv", sep=""))%>%
      rename(fhabinGU=avg, "sd.r"=sd, "n.r"=n)

    response=response1%>%
      left_join(response2, by=c("RS", "Unit", "Condition", "RScond"))
    
    
}

#if(upscale=="PercGU") # I need to make these outputs

#if(upscale=="PercHab")# I need to make these outputs
    
if(upscalevar=="ModelVal"){
  response=read.csv(paste(OUTdir, "\\", layer,"\\Selection\\",model ,"\\MedModelVal\\responseby", poolby, "_stats.csv", sep=""))%>%
    rename(modelval=avg, "sd.r"=sd, "n.r"=n)
  # I need to make these outputs
}
###Pooling Response#####
#Creats some join fields for pooling
#response$RSUnit=paste(response$RS,response$Unit, sep=" ")
#response$RScondUnit=paste(response$RScond,response$Unit, sep=" ")
#response$RScond=as.character(response$RScond)
#rmoves condition because it is added again during the joins below

response$Unit=as.character(response$Unit)
response$RScond=as.character(response$RScond)
response$RS=as.character(response$RS)
response=response%>%
  select(-Condition)


if(validateselection==T){
  GUTdir=paste(DATAdir,"\\GUTMetrics\\GUT2.1Run01" , sep="")
  GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]
siteresponse=read.csv(paste(GUTdir,GUToutputlist[grep(paste("site" , model, "response_",sep=""), GUToutputlist)],sep="\\"), stringsAsFactors=F)

sitemetrics=read.csv(paste(GUTdir,GUToutputlist[grep(paste("siteGUTmetrics_", layer, sep=""), GUToutputlist)],sep="\\"), stringsAsFactors=F)
#names(sitemetrics)[2]="visit"

S=selections%>%
  select(visit=visit, RScond=RScond,bfw=bfw)%>%
  extract(RScond, into = c("RS"), "(.[:upper:]*)", remove=F)%>%
  extract(RScond, into = c("Condition"), "([:lower:].*)", remove=F)
M=sitemetrics%>%
  select(visit=VisitID, BFArea, WEArea, No.GU,Length=MainThalwegL)
R=siteresponse%>%
  select(-X)

data=S%>%
  left_join(M, by="visit")%>%
  left_join(R, by="visit")


network=data%>%
  select(visit=visit, bfw=bfw, Length=Length, RS=RS, Condition0=Condition)

segIDcol="visit"
RScol="RS"
distcol="Length"
bfwcol="bfw"
condcols=c("Condition0")
Areacols=NA
}

#Finds position of columns related to defined header in network file
condcols.n=match(condcols,colnames(network))
RScol.n=which(colnames(network)==RScol)
segIDcol.n=which(colnames(network)==segIDcol)
RScol="RS"	

#upscalejoin=function{network, criteria, bfgu, Areacols, condcols.n, RScol.n, segIDol.n, RScol="RS", distcol.n, BFWcol.n}
#This is the part that does the upscaling onthe network
for(i in 1:length(condcols.n)) {
  if (is.na(Areacols) == F) {
    Areacols.n=match(Areacols,colnames(network))
    upscale = network[, c(segIDcol.n, RScol.n, condcols.n[i], Area=Areacols.n[i])]
    names(upscale)[4]="Area"
    upscale$RScond = paste(upscale[, 2], upscale[, 3], sep = "")
    
  } else {
    distcol.n=which(colnames(network)==distcol)
    BFWcol.n=which(colnames(network)==bfwcol)
    
    upscale0 = network[, c(segIDcol.n, distcol.n, BFWcol.n, RScol.n, condcols.n[i])]
    upscale0$RScond = paste(upscale0[, 4], upscale0[, 5], sep = "")
    #reads in scalar 'C' from criteria file
    Scalar=unite(criteria, "RScond" ,c("RS", "Condition"), sep="", remove=F)%>%
      select(RScond,C)
    upscale = upscale0 %>%
      left_join(Scalar, by = "RScond")
    upscale$Area = upscale[, 2] * upscale[, 3] * upscale$C
  }
  
  upscale1=upscale%>%
    full_join(bfgu, by="RScond")%>%
    #full_join(bfgu, by="RScond")%>%
    filter(!is.na(.[,1]))
  upscale1=upscale1[,-grep(".y",names(upscale1), fixed=T)]
  names(upscale1)=gsub(".x", "", names(upscale1), fixed=T)
  upscale1$RS=as.character(upscale1$RS)
  upscale1$Unit=as.character(upscale1$Unit)
  upscale1$Condition=as.character(upscale1$Condition)
  upscale1$RScond=as.character(upscale1$RScond)
  
  if(poolby=="RScond"){
    upscale2=upscale1%>%
    left_join(response, by=c("RScond","Unit","RS") )%>%
      filter(!is.na(.[,1]))
    #select(-RS)
  }
  
  if(poolby=="RS"){
    upscale2=upscale1%>% 
      right_join(response, by=c("RS" ,"Unit") )%>%
      filter(!is.na(.[,1]))
      #filter(!is.na(segmentID))%>%
      #select(-RS)
  }
  
  if(poolby=="none"){
    upscale2=upscale1%>% 
      right_join(response, by="Unit") %>%
      filter(!is.na(.[,1]))
      #filter(!is.na(segmentID))%>%
      #select(-RS)
  }

  
  
    #upscale3=upscale2[,-grep(".y",names(upscale2), fixed=T)]
    names(upscale2)=gsub(".x", "", names(upscale2), fixed=T)
   # return(upscale3)
#}
    
#Upscale Math
    
if(upscalevar=="Capacity" & ROI=="bf"){
    upscale2$bfwE=bfwE  
  upscale3=upscale2%>%
      mutate(var=Area*PercGU/100*bfdensity)%>%
      #mutate(varEw=abs(var)*sqrt( (bfwE/BFWest)^2+(sd/PercGU)^2+(sd.r/bfdensity)^2))%>%
      mutate(varSE=abs(var)*sqrt(((sd/sqrt(n))/PercGU)^2+((sd.r/sqrt(n.r))/bfdensity)^2))%>%
      mutate(varSD=abs(var)*sqrt((sd/PercGU)^2+(sd.r/bfdensity)^2))
    }
    
if(upscalevar=="Capacity" & ROI=="hydro"){
  print("Cannot upscale Capacity within hydro bounds at this time pick different upscalevar")}
    
if(upscalevar=="Capacity" & ROI=="hab"){
      upscale3=upscale2%>%
        mutate(var=Area*PercGU/100*fhabinGU*habdensity)
      }
    
if(upscalevar=="ModelVal"){
  upscale3=upscale2%>%
    mutate(var=modelval)
  }


if(validateselection==F){
  
    upscale3=upscale3%>%
    group_by(.[,1], RScond)
      
      if(upscalevar=="Capacity"){
        subreachupscale=upscale3%>% #summarize(cap=sum(cap), cap.m.sd=sum(cap.m.sd), cap.p.sd=sum(cap.p.sd), Length_m=max(Length_m), width_m=max(BFWest), StreamArea_m2=max(StreamArea))%>%
          summarize(var=sum(var, na.rm=T), varSD= sqrt(sum(varSD^2, na.rm=T)), varSE=sqrt(sum(varSE^2, na.rm=T)), Area=max(Area, na.rm=T))
          
      }
          #mutate(capby100L=cap/Length_m*100, capby100A=cap/StreamArea_m2*100)
      if(upscalevar=="ModelVal"){
    subreachupscale=upscale3%>%
          summarize(var=sum(var*PercGU, na.rm=T)/sum(PercGU, na.rm=T),  Area=max(Area, na.rm=T))
      }
          #mutate(capby100L=cap/Length_m*100, capby100A=cap/StreamArea_m2*100)
    subreachupscale=subreachupscale%>%mutate(Scenario=condcols[i])%>%ungroup()
    names(subreachupscale)[1]=segIDcol
}
    
  
if(validateselection==T){
  visitlist=levels(as.factor(upscale2[,1]))
  for(j in 1:length(visitlist)){
    
    subvreachupscale=upscale3%>%
        filter(.[,1]==visitlist[j])%>%
        group_by(RScond)
      
      if(upscalevar=="Capacity"){
        subvreachupscale=subvreachupscale%>% #summarize(cap=sum(cap), cap.m.sd=sum(cap.m.sd), cap.p.sd=sum(cap.p.sd), Length_m=max(Length_m), width_m=max(BFWest), StreamArea_m2=max(StreamArea))%>%
          summarize(var=sum(var, na.rm=T), Area=max(Area, na.rm=T))
      }
      #mutate(capby100L=cap/Length_m*100, capby100A=cap/StreamArea_m2*100)
      if(upscalevar=="ModelVal"){
        subvreachupscale=subvreachupscale%>%
          summarize(var=sum(var*PercGU, na.rm=T)/sum(PercGU, na.rm=T),  Area=max(Area, na.rm=T))
      }
      subvreachupscale=subvreachupscale%>%mutate(visit=visitlist[j])
    if(j==1){subreachupscale=subvreachupscale}else{subreachupscale=rbind(subreachupscale,subvreachupscale)}
  }
}
    
  
    if(i==1){reachupscale=subreachupscale}else{reachupscale=rbind(reachupscale,subreachupscale)}
}


#trying to get length into output and failing.
distcol.n=match(distcol,colnames(network))
reachupscale1=merge(network[,c(segIDcol.n,distcol.n)], as.data.frame(reachupscale), by=segIDcol)
names(reachupscale1)[2]="Length"
  
#arrange(as_tibble(reachupscale1), segment_ID, as.factor(Scenario))

#sort(reachupscale1, method=c("Scenario",segIDcol))



#Add # units to reach upscale.  Also Percent of each unit type.


if(validateselection==F){
  

globalupscale=reachupscale%>%
  group_by(Scenario)
  
  if(upscalevar=="Capacity"){
    globalupscale=globalupscale%>%summarize(var=sum(var,na.rm=T), varSD= sqrt(sum(varSD^2, na.rm=T)), varSE=sqrt(sum(varSE^2, na.rm=T)), Area=sum(Area,na.rm=T))}

  if(upscalevar=="ModelVal"){
  globalupscale=globalupscale%>%summarize(var=mean(var,na.rm=T), Area=sum(Area,na.rm=T))}
  
#reachupscale2=reachupscale%>%
#  spread(key="Scenario", value=response)

write.csv(reachupscale, paste(OUTfolder, "\\" ,"byreach.csv", sep=""), row.names=F)
write.csv(globalupscale, paste(OUTfolder, "\\", "bybasin.csv", sep=""), row.names=F)
}

if(validateselection==T){
write.csv(reachupscale, paste(OUTfolder, "\\" ,"Selection_validation.csv", sep=""), row.names=F)
globalupscale=NA
}

#validationdata=read.csv(paste(OUTfolder, "\\" ,"byreach_validation.csv", sep=""))
#head(validationdata)


print(paste("files written to: ", OUTfolder))


upscaling=list(reach=reachupscale, basin=globalupscale)

print(paste("layer = ", layer))
print(paste("model = ", model))
print(paste("ROI = ", ROI))
#print(paste("response = ", responsevar))
print(paste("poolby = ", poolby))
print(paste("upscale response = ", upscalevar))
#print(paste("upscale method = ", method))
print(paste("Scenario condcols=" ,condcols))
print(paste("Areacols=" ,Areacols))

print(upscaling)

if(makeplot==T){
  library(ggplot2)

  
  if(validateselection==F){
  #Stacked barplot
    
 plotdata=merge(network, as.data.frame(reachupscale), by=segIDcol)
 distcol.n=match(distcol,colnames(plotdata))
  names(plotdata)[distcol.n]="StreamL"
  
  plotdata=plotdata%>%
    group_by(Scenario,RScond.y)%>%
    summarize(var=sum(var),Area=sum(Area), StreamL=sum(StreamL))%>%
    extract(RScond.y, into = c("RS"), "(.[:upper:]*)", remove=F)%>%
    extract(RScond.y, into = c("Condition"), "([:lower:].*)", remove=F)
  

  
  mycolors=c(good="forest green", mod="gold", poor="firebrick1", intact="light blue")
  
  myplot= ggplot()+geom_col(data=plotdata, aes(x=Scenario, y=var/StreamL , fill=Condition))+
    scale_fill_manual(values = mycolors)+
    facet_grid( ~ RS) +
    facet_wrap( ~ RS, scales='fixed')+
    ylab(upscalevar)+
    xlab("")+
    theme(axis.text.x=element_text(angle=45,hjust=1))
  myplot
  
  #myplot+geom_col(data=plotdata, aes(x=Scenario, y=var/Length*100, fill=Condition))+
  #ylab(paste(upscalevar, " per 100 m",sep=""))
  
  
  if(plottype==".pdf"){
    ggsave(paste(OUTfolder, "\\", "ScenariocomparisonbyRS.pdf", sep=""), plot=myplot, width = 7, height = 5 )}
  
  if(plottype==".png"){
    ggsave(paste(OUTfolder, "\\", "ScenariocomparisonbyRS.png", sep=""), plot=myplot, width = 7, height = 5)}
  #png(paste(OUTdir,"\\", layer, "_assemblage.png", sep=""))}
  
  if(plottype==".tiff"){
    ggsave(paste(OUTfolder, "\\", "ScenariocomparisonbyRS.tiff", sep=""), plot=myplot, width = 7, height = 5)}
  }
    
 if(validateselection==T){
   
  data$visit=as.character(data$visit)
  
   joindata=reachupscale%>%
     extract(RScond, into = c("RS"), "(.[:upper:]*)", remove=F)%>%
     extract(RScond, into = c("Condition"), "([:lower:].*)", remove=F)%>%
     left_join(data, by=c("visit"))
   names(joindata)=gsub(".x", "", names(joindata), fixed=T)
   joindata=joindata[,-grep("[.]y", names(joindata))]
   
  # write.csv(joindata, paste(OUTfolder, "\\" ,"Selection_validationjoin.csv", sep=""), row.names=F)
   
   joindata1=na.omit(joindata)
   if(upscalevar=="Capacity"){
     X=as.numeric(joindata1$Capacity_M)
   }
   if(upscalevar=="ModelVal"){
     X=as.numeric(joindata1$MedModelVal_M)
   }
   Y=as.numeric(joindata1$var)

   mycolors=c(poor="red", mod="yellow", good="green", intact="purple")
   
   
   myplot= ggplot(data=joindata1)+
     scale_colour_manual(values = mycolors)+
     xlab(paste("directly modelled", upscalevar))+
     ylab(paste("upscaled estimate of" , upscalevar))

   
   validate=myplot+
     geom_label(aes(x=X, y=var, label=visit),hjust=0, vjust=0, label.size=0.1, label.padding=unit(0.1, "lines"))+
     geom_abline(intercept=0, slope=1, lty=1, lwd=1) +
     geom_point(aes(x=X, y=var, col=Condition, shape=RS))
   
   
   perAreavalidate=myplot+
     geom_label(aes(x=X/WEArea, y=var/WEArea, label=visit),hjust=0, vjust=0, label.size=0.1, label.padding=unit(0.1, "lines"))+
     geom_abline(intercept=0, slope=1, lty=1, lwd=1) +
     geom_point(aes(x=X/WEArea, y=var/WEArea, col=Condition, shape=RS))+
      xlab(paste("directly modelled" , responsevar, "in Wetted Extent"))+
     ylab(paste("upscaled estimate", , responsevar, "in Wetted Extent"))

    perLengthvalidate=myplot+
     geom_label(aes(x=X/Length, y=var/Length, label=visit),hjust=0, vjust=0, label.size=0.1, label.padding=unit(0.1, "lines"))+
     geom_abline(intercept=0, slope=1, lty=1, lwd=1) +
     geom_point(aes(x=X/Length, y=var/Length, col=Condition, shape=RS))+
     xlab(paste("directly modelled ", responsevar, " per 100 m ",sep=""))+
     ylab(paste("upscaled estimate of " ,responsevar, " per 100 m", sep=""))
   
   

   if(plottype==".pdf"){
     ggsave(paste(OUTfolder, "\\", "SelectionCapacityvalidation.pdf", sep=""), plot=Capacityvalidate, width = 7, height = 5 )
    ggsave(paste(OUTfolder, "\\", "SelectionCapacityperAreavalidation.pdf", sep=""), plot=CapacityperAreavalidate, width = 7, height = 5 )
    ggsave(paste(OUTfolder, "\\", "SelectionCapacityperLengthvalidation.pdf", sep=""), plot=CapacityperLengthvalidate, width = 7, height = 5 )}
   
   if(plottype==".png"){
     ggsave(paste(OUTfolder, "\\", "SelectionCapacityvalidation.png", sep=""), plot=Capacityvalidate, width = 7, height = 5)
      ggsave(paste(OUTfolder, "\\", "SelectionCapacityperAreavalidation.png", sep=""), plot=CapacityperAreavalidate, width = 7, height = 5 )
      ggsave(paste(OUTfolder, "\\", "SelectionCapacityperLengthvalidation.png", sep=""), plot=CapacityperLengthvalidate, width = 7, height = 5 )}
   
   if(plottype==".tiff"){
     ggsave(paste(OUTfolder, "\\",  "SelectionCapacityvalidation.tiff", sep=""), plot=Capacityvalidate, width = 7, height = 5)
    ggsave(paste(OUTfolder, "\\", "SelectionCapacityperAreavalidation.tiff", sep=""), plot=CapacityperAreavalidate, width = 7, height = 5 )
    ggsave(paste(OUTfolder, "\\", "SelectionCapacityperLengthvalidation.tiff", sep=""), plot=CapacityperLengthvalidate, width = 7, height = 5 )}
   
   
 }
  

  }

if(validateselection==T){
keepvars=c("criteria", "selections", "PROJdir","plottype", "DATAdir", "makeplot", "layer", "model", "ROI", "responsevar", "poolby",
           "upscalevar", "RScol", "validateselection")
}
if(validateselection==F){
  keepvars=c("criteria", "selections", "PROJdir","plottype", "DATAdir", "makeplot", "layer", "model", "ROI", "responsevar", "poolby", "network",
             "upscalevar", "RScol", "segIDcol" , "distcol", "bfwcol", "Areacols", "condcols","validateselection" )
}

rm(list=ls()[-match(x = keepvars, table = ls())])

#vars




#PLOTS UP SCENARIO PLOTS
 
# percchnge=(reachupscale.r$capby100L-reachupscale$capby100L)/reachupscale$capby100L*100
# #percchngep=(reachupscale.r$cap.p.sd-reachupscale$cap.p.sd)/reachupscale$100L.p.sd*100
# #percchngem=(reachupscale.r$cap.m.sd-reachupscale$cap.m.sd)/reachupscale$cap.m.sd*100
# 
# chnge=cbind(reachupscale[,c(1,5,6,7)], percchnge)%>%
#   full_join(AGA.data, by="segmentID")
# 
# lowrecovery=which(chnge$RecPotent=="Low Recovery Potential")
# goodcurrent=which(chnge$Condition=="Good")
# chngesub=chnge[-c(lowrecovery, goodcurrent),]
# 
# #boxplot(chngesub$percchnge~chngesub$RScurrent)
# 
# chngesum=chngesub%>%
#   group_by(as.factor(RScurrent))%>%
#   summarize(avg=mean(percchnge, na.rm=T), n=length(na.omit(percchnge)))
# 
# par(mfrow=c(2,1),mar=c(5,7,2,2))
# barplot(height=chngesum[-c(1:3,6,12),]$avg, 
#         names.arg=as.character(as.data.frame(chngesum[-c(1:3,6,12),])[,1]), 
#         horiz=T, las=2, xlab="Average %Change in Juvenile Rearing Capacity from Current to Restored",
#         xlim=c(-10,40))
# 
# barplot(height=chngesum[-c(1:3,6,12),]$avg, 
#         names.arg=as.character(as.data.frame(chngesum[-c(1:3,6,12),])[,1]), 
#         horiz=T, las=2, xlab="Average %Change in Spawning Capacity from Current to Restored",
#         ,xlim=c(-10,40))




