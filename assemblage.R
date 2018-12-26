#Estimates Empirical assemblages of geomorphic units as percent of bankful area of each unit type for
#reach selections from RSselection.R. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Nov 30th 2018

#This script uses output from supporting tools in the GUT Github respository \GitHub\PyGUT\SupportingTools\Rscripts\makeGUmetrics.
#Output from the database for Tier2_InChannel_Transitions and Three3_InChannel are included in the database folder.
#GitHub\GeomorphicUpscale\Database\GUTMetrics\GUT2.1Run01

##Functions#############
########################
#assemblage=function(GUTdir, selections, layer=""){ #I need to add capability of summarizing layers with or without transition.
  
  library(dplyr)
  library(tidyr)
  
OUTdir=paste(PROJdir,"Outputs", sep="\\")
if (file.exists(OUTdir)==F){dir.create(OUTdir)}
if (file.exists(paste(OUTdir,layer, sep="\\"))==F){dir.create(paste(OUTdir,layer, sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Selection" , sep="\\"))==F){dir.create(paste(OUTdir,layer, "Selection" , sep="\\"))}
if (file.exists(paste(OUTdir,layer, "Selection" ,"GU", sep="\\"))==F){dir.create(paste(OUTdir,layer, "Selection" ,"GU", sep="\\"))}


GUTdir=paste(DATAdir,"\\GUTMetrics\\GUT2.1Run01" , sep="")
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
  
  #Splits RScond into two additional columns, RS and Condition  


  RSlist=levels(selections$RScond) #create list of RS 

  for(i in 1:length(RSlist)){
    subdata1=filter(selections, RScond==RSlist[i])%>%
      select(RScond,visit)%>%
      left_join(unitdata, by="visit")%>%
      filter(!is.na(Unit))%>%
      group_by(Unit)%>%
      summarize(avg=mean(percArea, na.rm=T), 
                sd=sd(percArea, na.rm=T),
                med=median(percArea, na.rm=T), 
                min=min(percArea, na.rm=T) ,
                max=max(percArea, na.rm=T),
                n=length(na.omit(percArea)))%>%
      ungroup()

    subdata1$RScond=RSlist[i]
    if(i==1){assemblage0=subdata1}else{assemblage0=rbind(assemblage0,subdata1)}
  }
  
  assemblage=assemblage0%>%
    extract(RScond, into = c("RS"), "(.[:upper:]*)", remove=F)%>%
    extract(RScond, into = c("Condition"), "([:lower:].*)", remove=F)
  assemblage$RS

unitlist=levels(as.factor(as.character(assemblage$Unit)))

  slim=assemblage%>%
  #spreads table so that unit types are converted to columns and RSconds are rows.
    group_by(RScond)%>%
    select(-sd,-med,-min,-max,-n)%>%
    spread(key="Unit", value=avg)%>%
  #Splits RScond into two additional columns, RS and Condition  
    #extract(RScond, into = c("RS"), "(.[:upper:])", remove=F)%>%
    #extract(RScond, into = c("Condition"), "([:lower:].*)", remove=F)%>%
   #Renormalizes to 100  
    ungroup%>%
    mutate(SUM=select(.,-c(RScond:RS))%>% apply(1, sum, na.rm=T))%>%
    mutate_at(4:(3+length(unitlist)), funs(./SUM*100))%>%
    mutate(SUM=select(.,-c(RScond:RS,SUM))%>% apply(1, sum, na.rm=T))
  
  assemblages=list(assemblage_stats=assemblage, assemblage_est=slim)
  print(assemblages)
  
  write.csv(slim, paste(OUTdir, "\\", layer,"\\Selection\\GU\\", "\\assemblage_est.csv", sep=""), row.names=F)
  write.csv(assemblage, paste(OUTdir, "\\", layer,"\\Selection\\GU\\", "assemblage_stats.csv", sep=""), row.names=F)
  print(paste("files written to: ", OUTdir,"\\", layer,"\\Selection\\GU",  sep=""))
  
 # return(assemblages)
  

#}

###Variables###########
##GUTdir: The directory where the GUT metrics output files exist. This script uses the GUTunit
##selections: input table that has columns identifying the riverstyle type/condition as well as another column or columns that
##uniquely identify specific sites. Basically the output from RSselection sourced from "E:\\GitHub\\GeomorphicUpscale\\Scripts\\RSselection.R"
##layer: the GUT layer that you want summarize (Tier2_InChannel, Tier3_InChannel, Tier2_InChannel_Transitions). 
#######################

if(makeplot==T){
#assemblagechart=function(assemblage, layer="Tier2_InChannel_Transition", OUTdir=NA, plottype="none"){
  
require(ggplot2)
require(dplyr)
  
#Read in and manipulate data for plotting
cols=length(names(slim))  
mydata=gather(slim, key="Unit", value="Percent", 4:(cols-1))%>%
  select(-SUM)
mydata$Condition=factor(mydata$Condition, levels=c("poor", "mod", "good","intact"))

#Set plotting colors depending on layer
if(layer=="Tier2_InChannel_Transition"){
  mycolors= c(Bowl="royalblue",Mound="darkred",Plane="khaki1",Saddle="orange2",Trough="lightblue",Wall= "grey10",
              `Bowl Transition`="aquamarine", `Mound Transition`="pink")
  mydata$Unit=factor(mydata$Unit, levels=c("Bowl", "Bowl Transition", "Mound", "Mound Transition", "Saddle",
                                           "Trough", "Plane", "Wall"))
}
if(layer=="Tier2_InChannel"){
  mycolors= c(Bowl="royalblue",Mound="darkred",Plane="khaki1",Saddle="orange2",Trough="lightblue",Wall= "grey10")

  mydata$Unit=factor(mydata$Unit, levels=c("Bowl", "Mound", "Saddle","Trough", "Plane", "Wall"))
  
  }
if(layer=="Tier3_InChannel"){
  mycolors=c(`Pocket Pool`="light blue", Pool="royalblue", Pond="dark green", `Margin Attached Bar`="darkred", `Mid Channel Bar`="brown2" , 
  Riffle="orange2", Cascade="pink", Rapid="light green", Chute="aquamarine" ,
  `Glide-Run`="khaki1", Transition="grey70", Bank="grey10")
  
  mydata$Unit=factor(mydata$Unit, levels=c("Pocket Pool", "Pool", "Pond", "Margin Attached Bar", "Mid Channel Bar", 
                                                "Riffle", "Cascade", "Rapid", "Chute" ,
                                                "Glide-Run", "Transition", "Bank"))
}

###Makes the plot
myplot <- ggplot() +
  geom_bar (data=mydata, aes(y=Percent, x=Condition, fill=Unit), stat="identity",
            position='stack') +
  scale_fill_manual(values = mycolors)+
  facet_grid( ~ RS) +
  facet_wrap( ~ RS, scales='free')

print(myplot)

  
if(plottype==".pdf"){
  ggsave(paste(OUTdir, "\\", layer,"\\Selection\\" ,"GU\\", "assemblage.pdf", sep=""), plot=myplot, width = 7, height = 5 )}

if(plottype==".png"){
  ggsave(paste(OUTdir, "\\", layer,"\\Selection\\" ,"GU\\", "assemblage.png", sep=""), plot=myplot, width = 7, height = 5)}
  #png(paste(OUTdir,"\\", layer, "_assemblage.png", sep=""))}
  
  if(plottype==".tiff"){
    ggsave(paste(OUTdir, "\\", layer,"\\Selection\\" ,"GU\\", "assemblage.tiff", sep=""), plot=myplot, width = 7, height = 5)}

}
#}
  

  keepvars=c("criteria", "selections", "PROJdir","plottype", "DATAdir", "makeplot", "network", "layer")
  rm(list=ls()[-match(x = keepvars, table = ls())])
  
  
  
###Variables###########
##assemblage: the table of estimated percent areas for the assemblage.  The $assemblage_est output from the assemblage() function.
##layer: the GUT layer that you want summarize ("Tier2_InChannel", "Tier3_InChannel", "Tier2_InChannel_Transitions"). 
##OUTdir: The directory where you want to print the chart
##type: the file extension for the chart ("none", ".pdf", ".png", ".tiff")
#######################
#######################


##Example Usage#######
#OUTdir="E:\\GitHub\\GeomorphicUpscale\\docs\\assets"
#GUTdir="E:\\GitHub\\GeomorphicUpscale\\Database\\GUTMetrics\\GUT2.1Run01"
#myselections=read.csv("E:\\GitHub\\GeomorphicUpscale\\AsotinExampleData\\Inputs\\Asotinselections.csv")

#a=assemblage(GUTdir, myselections,  layer="Tier2_InChannel_Transition")
#assemblagechart(a$assemblage_est, layer="Tier2_InChannel_Transition", OUTdir=OUTdir, type=".tiff")
#write.csv(a$assemblage_stats,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier2_assemblage_stats.csv", row.names=F)
#write.csv(a$assemblage_est,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier2_assemblage_est.csv", row.names=F)


#b=assemblage(GUTdir, myselections, layer="Tier3_InChannel")
#assemblagechart(b$assemblage_est, layer="Tier3_InChannel", OUTdir=OUTdir, type=".tiff")
#write.csv(b$assemblage_stats,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier3_assemblage_stats.csv", row.names=F)
#write.csv(b$assemblage_est,"E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotin_Tier3_assemblage_est.csv", row.names=F)

#####################
