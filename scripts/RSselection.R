
#This script uses information within ReachSelectionCriteria.csv to select reaches within the GUT database
#that match geomorphically to specified geomorphic indicator characteristics. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated June 3, 2019


###########################################################
#Dependencies
###########################################################
library(dplyr)

###########################################################
#Define User File Path Directories
###########################################################

#User defined project directories Loation
PROJdir="...//MYUpscalePRoject"

#Local location of GeomorphicUpscale
DATAdir=paste("...//GeomorphicUpscale")

###########################################################
#Reads in specified data and defines script locations
###########################################################
#reads in database of reach variables.
data=read.csv(paste(DATAdir, "Database\\Database_reachcharacteristics.csv", sep="\\"))
head(data)


###########################################################
#Select River Styles empirical subsets using geoindicators
###########################################################
#selections for each river style and type.  Manually edit these to match criteria in your selection
#criteria look up table.  sorry this isn't more automated. But, this is a template which provides you
#with maximum flexibility to select as stringently or as un stringent as you desire. The trick is
#The trick is not to be too restrictive so that you end up with a large enough pool of sites 
#to acquire a good empirical estimate, but not so restrictive that you end up with sites that 
#don't look like your defined River Style.

#
#Before makeing individual selections for diferent river styles, you can eliminate certain type streams from the entire pool of database streams

data1=data%>%
  filter(Sndf<50)  #for example this will eliminate all streams with sand size fraction greater than 50% from the pool of available sites.

#Example selection options.  You won't use all available selection options, just the geo indicators that 
#give you the best subset for your river style type. Comment out any that you don't have data for or don't want to use. This might be iterative 
#because you want enough data to give you an adequate subset, but not too general that the streams found aren't representative of your river style and condition.

#Keep your River Style codes, short and easy to understand.  These will be carried through as the label identifier used for each River style
#if it has a condition varient add it after the code as "good" "moderate" or "poor" all in lower case.


# #River Style type 1 Selections-----------------------------------------------------


RS1good=data1%>%
  filter((Gradient < 3.5 & Gradient>1) 
         & Confinement!="UCV" 
         & Threads=="Single" 
         & Braid <1.4
         & Bedform=="Plane-Bed" 
#         & Sinuosity<1.1 
         & (LWfreq < 30 | is.na(LWfreq))
         #& Bldr>20
#        & Cbl>20
#         & Gvl>50
         &Sndf<10
#         & bfw/bfd>15
#         & bfw>20
#         & bfd>1
  )%>%
  mutate(RS="RSA",               #adds a column with your river style code associated with these selected sites
         Condition="moderate"    #adds a column with your river style condition code associated with these selected sites
  ) 
a #prints the selection to console for immediate feedback to see if it seems okay (not too large, small, etc.)
#



# #River Style type 2 Selections  -----------------------------------------------------
b=data1%>%
  filter((Gradient < 1 ) 
         & Threads=="Multi" 
#         & Braid <1.4
         & Bedform=="Plane-Bed" 
#         & Sinuosity>1.1 
         & Confinement!="CV" 
         & (LWfreq > 10 | is.na(LWfreq))
 #        & Bldr>20
#        & Cbl>20
#        & Gvl>50 
#        &Sndf<10
#         & bfw/bfd>15
         & bfw>10
#         & bfd>1
)%>%
  mutate(RS="RSB",               #adds a column with your river style code associated with these selected sites
         Condition="moderate"    #adds a column with your river style condition code associated with these selected sites
         ) 

b #prints the selection to console for immediate feedback to see if it seems okay (not too large, small, etc.)



###########################################################
#Combine selectiosn into one dataset and export to .csv
###########################################################
selections=rbind(a,b)%>%mutate(RScond=paste(RS, Condition, sep=""))

#Write file to INput director to be used in subsequent scripts ou can change the name if you want to
selectionfilename="selections"

INdir=paste(PROJdir, "Inputs", sep="\\")
if(file.exists(INdir)==F)(dir.create(INdir))

write.csv(selections, paste(INdir, "\\", selectionfilename, ".csv",  sep=""), row.names=F) 

###########################################################
###Copy Maps corresponding to selections for review
###########################################################

MAPrepo=paste(DATAdir, "Database\\Maps", sep="\\")

#set directory where selections .csv is housed
INdir=paste(PROJdir, "Inputs", sep="\\")
if(file.exists(INdir)==F)(dir.create(INdir))

##read in selections generated from RSselection.R
selections=read.csv(paste(INdir, "\\", selectionfilename, ".csv",  sep=""))

##specify output directory
OUTdir=paste(INdir, "Maps", sep="\\")
if(file.exists(OUTdir)==F){dir.create(OUTdir)}

##specify variables used in script

layer="Tier3_InChannel"
RScolname="RScond"
idcolname="visit"
idcolname2=NA

#soruce the geomorphic MapsbyRSselection from where it is locally saved.
source(paste(DATAdir, "\\scripts\\MapsbyRSselection.R", sep=""))



  