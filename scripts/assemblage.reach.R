#This script smmarizes geomorphic assemblages by reach

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated July 13 2019

#Documentation available on 
#https://natalie-kramer.github.io/GeomorphicUpscale/


# To Do -------------------------------------------------------------------

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

# set up data refs and output file structure  ------------------------------------------------------------------------

#Create Output subdirectories based on user variable choices
create.subdirs(PROJdir, c("Outputs", "assemblage",  gu.type, "by.reach"))

#specify OUTput directory as variable
OUTdir=paste(PROJdir, "Outputs","assemblage", gu.type, "by.reach",sep="\\")

#delete any existing files in Output from previous runs
unlink(paste(OUTdir,"\\*", sep=""), recursive=T)

#Specify location of input metric tables
GUTdir=paste(GUPdir,"\\Database\\Metrics" , sep="")

#specify GUT output layer to draw data from based on gu.type
#May need to change this in the future? depended on file naming conventions.
if(gu.type=="GU"){layer="Tier3_InChannel_GU"}
if(gu.type=="UnitForm" | gu.type=="UnitShape"){layer="Tier2_InChannel_Transition" }

#make list of GUT output matching layer
GUToutputlist=list.files(GUTdir)[grep(layer, list.files(GUTdir)) ]

# Read in data and summarize ----------------------------------------------

#Read in Site Data and convert to long data format
sitemetrics=read.csv(paste(GUTdir,GUToutputlist[grep("Site_GUT", GUToutputlist)],sep="\\"),stringsAsFactors=F)%>%
  filter(gut.layer==layer)%>%
  select(-gut.layer)%>%
  gather(value="value", key="variable", 2:10)

#combine site data with selections
sitedata=join.selection(selections, sitemetrics)%>%
  mutate(unit.type="all", ROI="bankfull")

#re-set wet area ROI to wetted.
sitedata$ROI[which(sitedata$variable=="wet.area.m2")]="wetted"

print("making summary tables and plots...")

#summarize data pooling in different ways and write to files
make.outputs(sitedata, poolby="", plottype, OUTdir=OUTdir, RSlevels=RSlevels)
make.outputs(sitedata, poolby="RS", plottype, OUTdir=OUTdir, RSlevels=RSlevels)
make.outputs(sitedata, poolby="RScond", plottype,OUTdir=OUTdir, RSlevels=RSlevels)

# cleaning up ----------------------------------------------

print("erasing temporary variables")

keepvars=c("PROJdir","GUPdir", "selections",
           "plottype", "myscales" , "RSlevels", "gu.type")
  rm(list=ls()[-match(x = keepvars, table = ls())])
  
print("done")
  
  
