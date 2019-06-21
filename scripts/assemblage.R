#Estimates Empirical assemblages of geomorphic units as percent of bankful area of each unit type for
#reach selections from RSselection.R. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated June 5 2019

#Documentation available on 
#https://natalie-kramer.github.io/GeomorphicUpscale/

###Dependencies####
require(ggplot2)
require(dplyr)

source(paste(GUPdir,"\\scripts\\create.subdirs.func" , sep=""))
source(paste(GUPdir, "\\scripts\\plot.colors.R", sep=""))

###################

if((layer=="Tier3_InChannel" & gu.type!="GU")|(layer!="Tier3_InChannel" & gu.type=="GU")
){  print("ERROR gu.type not compatible with layer, no output")
  }else{

#Create Output subdirectories based on user variable choices
create.subdirs(PROJdir, c("Outputs", "assemblage",  gu.type ,layer))

#specify OUTput directory as variable
OUTdir=paste(PROJdir, "Outputs","assemblage", gu.type,layer, sep="\\")

#Specify location of input metric tables
GUTdir=paste(GUPdir,"\\Database\\Metrics" , sep="")

#May need to change this in the future? depended on file naming conventions.  
#List GUToutput files corresponding to Layer
  GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]
  
#Read in Unit Data
  unitmetrics=read.csv(paste(GUTdir,GUToutputlist[grep("Unit_GUT", GUToutputlist)],sep="\\"),stringsAsFactors=F)
  
#makes a list of all the visits
  visitlist=levels(as.factor(unitmetrics$visit.id))
  
  #makes into long format
  #I could also have it automatically analyze by unit shape, not just unit form.
  
  unitdata.gather=unitmetrics%>%filter(gut.layer==gu.type)%>%select(-gut.layer)%>%
    gather(value="value", key="variable", 3:13)
  
  #unitdata.gather=unitmetrics%>%gather(value="value", key="variable", 4:14)

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
      #group_by(RS, Condition, gut.layer, unit.type, variable)%>%
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
  

#function to summarize by geomorphic unit  
#make.slim.table=function(GUTlayer){  

  #assemblage1=assemblage%>%filter(gut.layer==GUTlayer)%>%select(-gut.layer)
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
#}

#summarize based on tier 3 GU 
#if(layer=="Tier3_InChannel"){
# slim=make.slim.table(GUTlayer="GU")
# assemblages=list(assemblage_stats=assemblage, assemblage.gu_est=slim)
# write.csv(slim, paste(OUTdir,"\\assemblage.gu_est.csv", sep=""), row.names=F)
#} 

#I should probably change this so that form and shape are user defined variables specifying what is of interest.
#summarize based on Tier 2 form and shape
#if(layer=="Tier2_InChannel"|layer=="Tier2_InChannel_Transition" ){
#  slim=make.slim.table(GUTlayer="UnitForm")
#  slim.shape=make.slim.table(GUTlayer="UnitShape")
#  assemblages=list(assemblage_stats=assemblage, assemblage.form_est=slim, assemblage.shape_est=slim.shape)
#  write.csv(slim, paste(OUTdir,"\\assemblage.form_est.csv", sep=""), row.names=F)
#  write.csv(slim, paste(OUTdir,"\\assemblage.shape_est.csv", sep=""), row.names=F)
#  }
  
assemblages=list(assemblage_stats=assemblage, assemblage_est=slim)
print(assemblages)

#write to output .csv


write.csv(assemblage, paste(OUTdir, "\\assemblage_stats.csv", sep=""), row.names=F)
write.csv(slim, paste(OUTdir,"\\assemblage_est.csv", sep=""), row.names=F)
print(paste("files written to: ", OUTdir,  sep=" "))
  

#prints plots
#######################
print("making plots...")
  
if(makeplot==T){
 
#Read in and manipulate data for plotting
cols=length(names(slim))  
mydata=gather(slim, key="Unit", value="value", 3:(cols))

#condition levels for plots hard coded as "poor", "mod", "good" to show up in correct order
mydata$Condition=factor(mydata$Condition, levels=c("poor", "mod", "good"))

#Set plotting colors depending on layer
if(gu.type=="UnitShape"){
mycolors= shape.fill
mydata$Unit=factor(mydata$Unit, 
                   levels=c("Concavity", "Planar", "Convexity"))
}

if(gu.type=="UnitForm"){
mycolors= form.fill

if(layer=="Tier2_InChannel_Transition"){
  mydata$Unit=factor(mydata$Unit, 
                     levels=c("Bowl", "Bowl Transition", "Mound", "Mound Transition", "Saddle",
                                           "Trough", "Plane", "Wall"))
}
if(layer=="Tier2_InChannel"){
  mydata$Unit=factor(mydata$Unit, 
                     levels=c("Bowl", "Mound", "Saddle","Trough", "Plane", "Wall"))
  
}
}


if(layer=="Tier3_InChannel"){
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

  
  keepvars=c("selections", "PROJdir","plottype", "GUPdir", "makeplot", "network", "layer","braid.index", "gu.type")
  rm(list=ls()[-match(x = keepvars, table = ls())])
  
  print("done")
  
  }
