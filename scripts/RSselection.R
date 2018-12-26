
#This script uses information within ReachSelectionCriteria.csv to select reaches within the GUT database
#that match geomorphically to specified geomorphic indicator characteristics. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Dec 7, 2018


#Local location of database
DATAdir="E://GitHub//GeomorphicUpscale//Database"
#User defined project directories Loation
PROJdir='E:\\GitHub\\GeomorphicUpscale\\AsotinExampleData'
criteriafile="E:\\PantherUpscale\\Inputs\\AsotinReachSelectionCriteria.csv"

#Specify location of R Mapping Script
#CODEdir= paste(PROJdir, "scripts", sep="\\")
#MapsbyRSselection=paste(CODEdir, "MapsbyRSselection.R", sep="\\")

#reads in user defined criteria
INdir=paste(PROJdir, "Inputs", sep="\\")
criteria=read.csv(criteriafile, skip=20) #skip= specifies # header rows to skip at beginning of csv, you may need to change
head(criteria)

#reads in database of reach variables.
data1=read.csv(paste(DATAdir, "Database_reachcharacteristics.csv", sep="\\"))
head(data1)

###########################################################
#Dependencies
###########################################################
#load('E:\\GitHub\\GeomorphicUpscale\\UnitSummary.R') #isn't reading in correctly?
library(dplyr)

###########################################################
#Selections
###########################################################
#selections for each river style and type.  Manually edit these to match criteria in your selection
#criteria look up table.  sorry this isn't more automated. But, this is a template which provides you
#with maximum flexibility to select as stringently or as un stringent as you desire. The trick is
#The trick is not to be too restrictive so that you end up with a large enough pool of sites 
#to acquire a good empirical estimate, but not so restrictive that you end up with sites that 
#don't look like your defined River Style.
criteria


#Since all Asotin streams are boulder-cobble-gravel.  I want to eliminate from the data
#All streams with sand size fraction greater than 50%

sandystreams=data1%>%
 filter(Sndf>50)
sandystreams #this search will eliminate four reaches visits 820,1971,2288,3975

data=data1%>%
  filter(Sndf<50)

#Example selection options.  You won't use all available selection options, just the geo indicators that 
#give you the best subset for your river style type.
#selection=data%>%
#  filter((Gradient < 3.5 & Gradient>1) 
#         & Threads=="Single" 
#         & Braid <1.4
#         & Bedform=="Plane-Bed" 
#         & Sinuosity<1.1 
#         & Confinement!="UCV" 
#         & (LWfreq < 30 | is.na(LWfreq))
#         & Bldr>20
#         & Cbl>20
#         & Gvl>50
#         &Sndf<10
#         & bfw/bfd>15
#         & bfw>20
#         & bfd>1
#  )




## Asotin RS Example Selection


#Example selection options.  You won't use all available selection options, just the geo indicators that 
#give you the best subset for your river style type.
#yourRScond=data%>%
#  filter((Gradient < 3.5 & Gradient>1) 
#         & Threads=="Single" 
#         & Braid <1.4
#         & Bedform=="Plane-Bed" 
#         & Sinuosity<1.1 
#         & Confinement!="UCV" 
#         & (LWfreq < 30 | is.na(LWfreq))
#         & Bldr>20
#         & Cbl>20
#         & Gvl>50
#         &Sndf<10
#         & bfw/bfd>15
#         & bfw>20
#         & bfd>1
#  )
#yourRScond$RScond="FCmod"
#yourRScond

#COMBINE YOUR SELECTIONS
selections=rbind(,,,,,,)


#combine your selections above into one dataset
#selections=rbind(FCpoor,FCmod, FCgood, FCintact,
#                 AFpoor,AFmod, AFgood, AFintact,
#                 PCpoor,PCmod, PCgood, PCintact,
#                 WApoor, WAmod, WAgood,WAintact,
#                 CVpoor, CVmod, CVgood, CVintact)


#Write file to INput director to be used in subsequent scripts ou can change the name if you want to
selectionfilename="Asotinselections"

write.csv(selections, paste(INdir, "\\", selectionfilename, ".csv",  sep=""), row.names=F) 

#######Copy Mapys corresponding to selections for review#################

MAPrepo=paste(DATAdir, "\\Maps", selectionname, sep="")

##read in selections generated from RSselection.R
selections=read.csv("E:\\PantherUpscale\\Inputs\\Pantherselections.csv")

layer="Tier3_InChannel"
RScolname="RScond"
idcolname="visit"
idcolname2=NA

source("E:\\GitHub\\GeomorphicUpscale\\scripts\\MapsbyRSselection.R")
#source(MapsbyRSselection)

  