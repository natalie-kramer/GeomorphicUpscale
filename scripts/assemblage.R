#Estimates Empirical assemblages of geomorphic units as percent of bankful area of each unit type for
#reach selections from RSselection.R. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated June 5 2019

#Documentation available on 
#https://natalie-kramer.github.io/GeomorphicUpscale/

###Dependencies####
require(ggplot2)
require(dplyr)
###################

##Functions#############
########################

source(paste(GUPdir,"\\scripts\\create.subdirs.func" , sep=""))
create.subdirs(PROJdir, c("Outputs",layer, "Selection", "GU"))

OUTdir=paste(PROJdir, "Outputs",layer, "Selection", "GU", sep="\\")

#GUTdir=paste(DATAdir,"\\GUTMetrics\\GUT2.1Run01" , sep="")
GUTdir=paste(GUPdir,"\\Database\\Metrics" , sep="")
  #List GUToutput files corresponding to Layer
  GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]
  
  #Read in Unit Data
  unitmetrics=read.csv(paste(GUTdir,GUToutputlist[grep("Unit", GUToutputlist)],sep="\\"),stringsAsFactors=F)
  
  #makes a list of all the visits
  visitlist=levels(as.factor(unitmetrics$visit.id))
  
  #makes into long format
  unitdata.gather=unitmetrics%>%select(-gut.layer)%>%
    gather(value="value", key="variable", 3:13)

  #create list of RS from which to gather summaries
    selections=selections%>%mutate(RScond=paste(RS, Condition, sep=""))
  RSlist=levels(as.factor(selections$RScond)) #create list of RS 

  print("making summary tables...")
  
  #summarize variables in GUT summary
  for(i in 1:length(RSlist)){
    subdata1=filter(selections, RScond==RSlist[i])%>%
      select(RS, Condition, RScond,visit.id)%>%
      left_join(unitdata.gather, by="visit.id")%>%
      filter(!is.na(unit.type))%>%
      group_by(RS, Condition, unit.type, variable)%>%
      summarize(avg=mean(value, na.rm=T), 
                sd=sd(value, na.rm=T),
                med=median(value, na.rm=T), 
                min=min(value, na.rm=T) ,
                max=max(value, na.rm=T),
                n=length(na.omit(value)))%>%
      ungroup()

    #subdata1$RScond=RSlist[i]
    if(i==1){assemblage=subdata1}else{assemblage=rbind(assemblage,subdata1)}
  }
  
unitlist=levels(as.factor(as.character(assemblage$unit.type)))

#spreads table so that unit types are converted to columns.
#I want to make it so that I have a slim table for EACH variable. right now just proportions.
  slim=assemblage%>%filter(variable=="area.ratio")%>%
     group_by(RS, Condition)%>%
    select(-sd,-med,-min,-max,-n,-variable)%>%
    #mutate(avg=avg*100)%>%
    spread(key="unit.type", value=avg)%>%
   #Renormalizes to 100  
    ungroup%>%
    mutate(SUM=select(.,-c(RS,Condition))%>% apply(1, sum, na.rm=T))%>%
    #mutate_at(4:(3+length(unitlist)), funs(./SUM*100))%>%
    mutate_at(3:(2+length(unitlist)), funs(./SUM))%>%
    mutate(SUM1=select(.,-c(RS,Condition,SUM))%>% apply(1, sum, na.rm=T))%>%
    select(-SUM,-SUM1)

  assemblages=list(assemblage_stats=assemblage, assemblage_est=slim)
  print(assemblages)

#saves output csv
  write.csv(slim, paste(OUTdir,"\\assemblage_est.csv", sep=""), row.names=F)
  write.csv(assemblage, paste(OUTdir, "\\assemblage_stats.csv", sep=""), row.names=F)
  print(paste("files written to: ", OUTdir,  sep=" "))
  
#prints plots
#######################
print("making plots...")
  
if(makeplot==T){
#assemblagechart=function(assemblage, layer="Tier2_InChannel_Transition", OUTdir=NA, plottype="none"){
  
#Read in and manipulate data for plotting
cols=length(names(slim))  
mydata=gather(slim, key="Unit", value="value", 3:(cols))

#condition levels for plots hard coded as "poor", "mod", "good" to show up in correct order
mydata$Condition=factor(mydata$Condition, levels=c("poor", "mod", "good"))

#Set plotting colors depending on layer
#I need to fix this to match sara.

source(paste(GUPdir, "\\scripts\\plot.colors.R", sep=""))


if(layer=="Tier2_InChannel_Transition"){
  mycolors= form.fil
  mydata$Unit=factor(mydata$Unit, 
                     levels=c("Bowl", "Bowl Transition", "Mound", "Mound Transition", "Saddle",
                                           "Trough", "Plane", "Wall"))
}
if(layer=="Tier2_InChannel"){
  mycolors= form.fill

  mydata$Unit=factor(mydata$Unit, 
                     levels=c("Bowl", "Mound", "Saddle","Trough", "Plane", "Wall"))
  
  }
if(layer=="Tier3_InChannel"){
  # set gut form and gu colors

  
  mycolors=gu.fill
    mydata$Unit=factor(mydata$Unit, 
                       levels=c("Pocket Pool","Pool", "Pond", 
                                "Margin Attached Bar","Mid Channel Bar", "Riffle",
                                "Cascade", "Rapid", "Chute" ,
                                "Glide-Run", "Transition", "Bank"))
}

###Makes the plot
myplot <- ggplot() +
  geom_bar (data=mydata, aes(y=value, x=Condition, fill=Unit), stat="identity",
            position='stack') +
  scale_fill_manual(values = mycolors)+
  facet_grid( ~ RS) +
  facet_wrap( ~ RS, scales='free')

print(myplot)

  
if(plottype==".pdf"){
  ggsave(paste(OUTdir,  "\\assemblage.pdf", sep=""), plot=myplot, width = 7, height = 5 )}

if(plottype==".png"){
  ggsave(paste(OUTdir, "\\assemblage.png", sep=""), plot=myplot, width = 7, height = 5)}
  #png(paste(OUTdir,"\\", layer, "_assemblage.png", sep=""))}
  
  if(plottype==".tiff"){
    ggsave(paste(OUTdir, "\\assemblage.tiff", sep=""), plot=myplot, width = 7, height = 5)}

}


  print("erasing temporary variables")

  
  keepvars=c("selections", "PROJdir","plottype", "GUPdir", "makeplot", "network", "layer","braid.index")
  rm(list=ls()[-match(x = keepvars, table = ls())])
  
  print("done")
  
