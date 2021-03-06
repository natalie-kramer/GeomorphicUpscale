
#This script takes the OUtput from GUT and summarizes responses by reach

#This script smmarizes geomorphic assemblages by reach

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated July 13 2019

#Documentation available on 
#https://natalie-kramer.github.io/GeomorphicUpscale/


# To Do -------------------------------------------------------------------
#Do response by size by RS and no pooling?, currently just RScond---if folders are flip flopped, this makes it easier...
#I need to add the lineear model results for response by size
#flip flop RScond folders with response types so that it mirrors the other outputs in long format for unit responses.

#eliminate species and model from directory structure and instead include as field in output table?  Maybe append to this table
#when run for different species or just run for all species and model types on the fly-- not make a user variable...?

# Dependencies ------------------------------------------------------------

require(ggplot2)
require(dplyr)
require(tidyr)

source(paste(GUPdir, "\\scripts\\plot.colors.R", sep=""))
source(paste(GUPdir, "\\scripts\\functions.R", sep=""))

###user variables defined in UpscaleWrapper.R###
PROJdir=PROJdir  #directory path to local project
GUPdir=GUPdir   #directory path to Github repo
selections=selections #directory path to input selections file generated by RSselection.R
gu.type=gu.type      #Options: UnitForm, GU #UnitShape not available at this time since I don't have maps of these in the database
RSlevels=RSlevels #optional vector argument to set RS factor order in graphs and displays, leave as  NA if alphabetical is desired
plottype=plottype   #Options: .tiff, .png, .pdf, "none"
myscales=myscales #Options: fixed or free x/y axis scales for tiled plot output
species=species   #Options: steelhead, chinook, ""
model=model    ##Options: nrei, fuzzy, ""
lifestage=lifestage  ##Options: spawner, juvenile

# set up data refs and output file structure  ------------------------------------------------------------------------

#make lifestage match model type    
if(model=="nrei"& lifestage!="juvenile"){lifestage="juvenile"
print("lifestage changed to juvenile for nrei results")}

#if(model=="fuzzy"){lifestage="spawner"
#print("lifestage set to spawner to match specified model")}

basesubdir=c("Outputs","response",  species, model,lifestage)

#specify subdirectories in Outputs according to output variables 
create.subdirs(PROJdir, c(basesubdir, "by.reach", "pred.fish"))
create.subdirs(PROJdir,c(basesubdir, "by.reach", "pred.fish_perLength_m"))
create.subdirs(PROJdir,c(basesubdir, "by.reach","pred.fish_perArea_m2"))

#Specify location of input metric tables
GUTdir=paste(GUPdir,"\\Database\\Metrics" , sep="")

#specify GUT output layer to draw data from based on gu.type
if(gu.type=="GU"){layer="Tier3_InChannel_GU"}
if(gu.type=="UnitForm" | gu.type=="UnitShape"){layer="Tier2_InChannel_Transition" }

#May need to change this in the future? depended on file naming conventions.  
#List GUToutput files corresponding to Layer
GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]

#read in site metric fish data
sitefishmetrics=read.csv(paste(GUTdir,"Site_Fish_Metrics.csv",sep="\\"),stringsAsFactors=F)

#makes layer with just site level resonse for model, species and lifestage specified.
myvars=c(model, species, lifestage)
sitefish=sitefishmetrics%>%filter(model==myvars[1] & species==myvars[2] & lifestage==myvars[3] & var=="pred.fish")
if(length(sitefish[,1])==0){print("no results for specified species, model and lifestage")}


# make site summaries for different response and ROI -----------------------


#just predicted fish total in reach 
a=sitefish%>%filter(category=="reach")%>%mutate(ROI="hydro")%>%select(visit.id, var, value, ROI)
#just predicted fish total in suitablehab (should match reach)
a2=sitefish%>%filter(category=="suitable")%>%mutate(ROI="suitablehab")%>%select(visit.id, var, value, ROI)
# just pred fish within the best habitat
b=sitefish%>%filter(category=="best")%>%mutate(ROI="besthab")%>%select(visit.id, var, value, ROI)

#makes layer with just the length of the thalwegs within the hydro modelling extent
sitehydrothalweg=sitefishmetrics%>%filter(layer=="thalweg", category=="main") #check with Sarah about different thalweg lengths based on different models
c=sitehydrothalweg%>%full_join(a, by="visit.id")%>%
  mutate(value=value.y/value.x, var="pred.fish_perLength_m")%>% select(visit.id, var, value, ROI)

#density by specified ROI
compute.densitybyROI=function(ROI, label){
#makes layer of hydro area within hydro modelling extent
sitehydroarea=sitefishmetrics%>%filter(var=="area",layer==model,species==species, lifestage==lifestage, category==ROI)
data=sitehydroarea%>%full_join(filter(sitefish, category==ROI), by="visit.id")%>%
  mutate(value=value.y/value.x, var="pred.fish_perArea_m2", ROI=label)%>% select(visit.id, var, value, ROI)
return(data)
}
d=compute.densitybyROI("best", label="besthab")
e=compute.densitybyROI("suitable", label="suitablehab") #These #s are not correct with this version of dbase
f=compute.densitybyROI("reach", label="hydro")

#computes density spread over entire BF area rather than hydro extent. sort of fictitious but needed for upscaling.
g=read.csv(paste(GUTdir,GUToutputlist[grep("Site_GUT", GUToutputlist)],sep="\\"),stringsAsFactors=F)%>%
  rename(area=bf.area.m2, thalweg=main.thalweg.length.m)%>%
  select(visit.id, area, thalweg) %>%
  full_join(a, by="visit.id")%>%
  mutate(pred.fish_perLength_m2=value/thalweg, pred.fish_perArea_m2=value/area, ROI="bankfull" )%>%
  gather(value="value", key="var", 7:8)%>%
  select(visit.id, value, var, ROI)


####combines output with selections##
siteresponse=join.selection(selections, rbind(a,a2, b,c,d,e,f,g))%>%rename(variable=var)%>%
mutate(unit.type="all")

#function to summarize data pooling in different ways and write to files
alloutputs=function(){
make.outputs(mydata, poolby="", plottype, OUTdir, myfacet="ROI", myscales='fixed', RSlevels)
make.outputs(mydata, poolby="RS", plottype, OUTdir,myfacet="ROI",myscales='fixed', RSlevels)
make.outputs(mydata, poolby="RScond", plottype, OUTdir,myfacet="ROI",myscales='fixed', RSlevels)
}

print("Making site level fish response summaries and plots")

#make output for predicted fish response
#set output directory
OUTdir=paste(PROJdir, paste(c(basesubdir, "by.reach" ,"pred.fish"), collapse="\\"), sep="\\")
#delete any existing files in Output from previous runs
unlink(paste(OUTdir,"\\*", sep=""), recursive=T)
#set data
mydata=siteresponse%>%filter(variable=="pred.fish")
#make summaries
alloutputs()

#make output for predicted fish response by stream L
#specify output directory
OUTdir=paste(PROJdir, paste(c(basesubdir, "by.reach","pred.fish_perLength_m"), collapse="\\"), sep="\\")
#delete any existing files in Output from previous runs
unlink(paste(OUTdir,"\\*", sep=""), recursive=T)
#set data
mydata=siteresponse%>%filter(variable=="pred.fish_perLength_m")
#make summaries
alloutputs()

#make output for predicted fish response by stream Area
#specify output directory
OUTdir=paste(PROJdir, paste(c(basesubdir,"by.reach", "pred.fish_perArea_m2"), collapse="\\"), sep="\\")
#delete any existing files in Output from previous runs
unlink(paste(OUTdir,"\\*", sep=""), recursive=T)
#set data
mydata=siteresponse%>%filter(variable=="pred.fish_perArea_m2")
#make summaries
alloutputs()

# make site summaries  of response by reach size  -----------------------

print("making site summaries of response by reach size")

#makesite level variables
pred.fish=sitefishmetrics[which(sitefishmetrics$category=="reach" & sitefishmetrics$var=="pred.fish" & sitefishmetrics$layer==model & sitefishmetrics$species==species),]
mainthalweg=sitefishmetrics%>%filter(category=="main" & var=="length")
hydroarea=sitefishmetrics[which(sitefishmetrics$category=="reach" & sitefishmetrics$var=="area" & sitefishmetrics$layer==model & sitefishmetrics$species==species),]

#combine and get ready the data
siteresponse.2=selections%>%
  full_join(pred.fish, by=c("visit.id"))%>%
  full_join(mainthalweg, by="visit.id")%>%
  full_join(hydroarea, by="visit.id")%>%
  filter(RS!=is.na(RS))%>%
  select(visit.id, RS, Condition, value.x, Braid, bfw, bfd, value.y, value)%>%
  rename(hydrolength=value.y, pred.fish=value.x, hydroarea=value)%>%
  mutate(volume=hydroarea*bfd, model=myvars[1], species=myvars[2], lifestage=myvars[3])

#set outputdirectory
OUTdir=paste(PROJdir, paste(c(basesubdir, "by.reach", "pred.fish" ), collapse="\\"), sep="\\")
#delete any existing files in Output from previous runs
unlink(paste(OUTdir,"\\*", sep=""), recursive=F)

#write to file
write.csv(siteresponse.2, paste(OUTdir ,"\\by.reachsize.csv", sep=""), row.names=F)

#sets order for RS factor levels
if(is.na(RSlevels)[1]==F){
siteresponse.2$RS=factor(siteresponse.2$RS,levels=RSlevels)}

#create base plot
#TO DO: add regression OUTPUT summaries
p=ggplot(siteresponse.2)+aes(y=pred.fish, color=Condition)+
  scale_colour_manual(values = condition.fill)+
  facet_grid(Condition~RS, scales=myscales)

#plot
h=p+geom_point(aes(x=bfw))
i=p+geom_point(aes(x=bfd))
j=p+geom_point(aes(x=hydrolength/10))
k=p+geom_point(aes(x=volume/1000)) #This is hydroarea*bfd, not perfect, better to have average hydrodepth, but I don't have that variable.
l=p+geom_point(aes(x=Braid))
m=p+geom_point(aes(x=hydroarea/100)) 

print("plotting response by stream size graphs")
#save
ggsave(paste(OUTdir,"\\by_width.bankfull_m", plottype, sep=""), plot=h, width = 15, height = 5 )
ggsave(paste(OUTdir,"\\by_depth.bankfull_m", plottype, sep=""), plot=i, width = 15, height = 5 )
ggsave(paste(OUTdir,"\\by_length.hydro_m", plottype, sep=""), plot=j, width = 15, height = 5 )
ggsave(paste(OUTdir,"\\by_volume.as.hydroarea.bfdepth_m3", plottype, sep=""), plot=k, width = 15, height = 5 )
ggsave(paste(OUTdir,"\\by_braid.index.champ", plottype, sep=""), plot=l, width = 15, height = 5 )
ggsave(paste(OUTdir,"\\by_area.hydro_m2", plottype, sep=""), plot=m, width = 15, height = 5 )

# cleaning up ----------------------------------------------

print("erasing temporary variables")


keepvars=c("selections", "PROJdir","GUPdir", "plottype", "myscales" , "RSlevels", "gu.type", 
           "species", "model", "lifestage")
    
rm(list=ls()[-match(x = keepvars, table = ls())])

print("done")





