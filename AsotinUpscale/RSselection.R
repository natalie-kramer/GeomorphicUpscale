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
PROJdir="E:\\AsotinUpscale"

#Local location of GeomorphicUpscale
DATAdir=paste("E:\\GitHub\\GeomorphicUpscale")

###########################################################
#Reads in specified data and defines script locations
###########################################################
#reads in database of reach variables.
data1=read.csv(paste(DATAdir, "Database\\Database_reachcharacteristics.csv", sep="\\"))
head(data1) #preview the top of teh database.


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

sandystreams=data1%>%
  filter(Sndf>50)
sandystreams #this search will eliminate four reaches visits 820,1971,2288,3975

data=data1%>%
  filter(Sndf<50)

#Example selection options.  You won't use all available selection options, just the geo indicators that 
#give you the best subset for your river style type. Comment out any that you don't have data for or don't want to use. This might be iterative 
#because you want enough data to give you an adequate subset, but not too general that the streams found aren't representative of your river style and condition.

#Keep your River Style codes, short and easy to understand.  These will be carried through as the label identifier used for each River style
#if it has a condition varient add it after the code as "good" "moderate" or "poor" all in lower case.


# Fan Controlled-poor (FC poor) -----------------------------------------------------
FCpoor=data1%>%
  filter(((Gradient < 3.5 & Gradient>1)|Gradient==1)
         & Confinement!="UCV" 
         & Threads=="Single" 
         & Bedform=="Plane-Bed"
         & Sinuosity<1.1 
         & (LWfreq < 30 | is.na(LWfreq))
         
  )%>%
  mutate(RS="FC", Condition="poor")
FCpoor
summary(FCpoor)
length(FCpoor[,1]) #10

# Fan Controlled-mod (FC mod)-----------------------------------------------------

FCmod=data%>%
  filter(((Gradient < 3.5 & Gradient>1)|Gradient==1)
         & Confinement!="UCV" 
         & Threads=="Single" 
         & (Bedform=="Plane-Bed"| Bedform=="Pool-Riffle")  
         & (Sinuosity<1.3 & Sinuosity>1.04) 
 
         & (LWfreq < 60  | is.na(LWfreq))
  )%>%mutate(RS="FC", Condition="moderate")
FCmod
summary(FCmod)
length(FCmod[,1]) #19

# Fan Controlled-good (FC good) -----------------------------------------------------


FCgood=data%>%
  filter(((Gradient < 3.5 & Gradient>1)|Gradient==1)
         & Confinement!="UCV" 
         & Threads!="Multi" 
         & Bedform!="Plane-Bed"
         & (Sinuosity<1.5 & Sinuosity>1.1) 
         & (LWfreq > 10 | is.na(LWfreq))
  )%>%mutate(RS="FC", Condition="good")
FCgood
summary(FCgood)
length(FCgood[,1]) #5




# Alluvial Fan-poor (AF poor) -----------------------------------------------------

AFpoor=data%>%
  filter(
    Gradient < 3  
    & Confinement!="CV"  
    & Threads=="Single" 
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.2
    & (LWfreq < 30 | is.na(LWfreq))
  )%>%mutate(RS="AF", Condition="poor")
AFpoor
summary(AFpoor)
length(AFpoor[,1]) #19

# Alluvial Fan-mod (AF mod) -----------------------------------------------------

AFmod=data%>%
  filter(
    Gradient < 3 
    & Confinement!="CV"  
    & (Threads=="Single" | Threads=="Transitional")
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.3

    & ((LWfreq < 60 & LWfreq > 10)| is.na(LWfreq))
   # & ((LWfreq < 60 | is.na(LWfreq)))
  )%>%mutate(RS="AF", Condition="moderate")
AFmod
summary(AFmod)
length(AFmod[,1]) #12


# Alluvial Fan-good (AF good) -----------------------------------------------------

AFgood=data%>%
  filter(
    Gradient < 3 
    & (Threads=="Single" | Threads=="Transitional" | Threads=="Multi")
    # & (Braid < 5)
    & (Bedform=="Plane-Bed" | Bedform=="Pool-Riffle")
    & (Sinuosity<1.5 & Sinuosity >1.1)
    & Confinement!="CV" 
    & (LWfreq > 20| is.na(LWfreq))
  )%>%mutate(RS="AF", Condition="good")
AFgood
summary(AFgood)
length(AFgood[,1]) #18






# Planform Controlled-poor (PC poor) -----------------------------------------------------
PCpoor=data%>%
  filter(
    Gradient < 2.5  
    & Confinement!="CV"
    & Threads=="Single" 
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.1 
    & (LWfreq<30| is.na(LWfreq))
  )%>%mutate(RS="PC", Condition="poor")
PCpoor
summary(PCpoor)
length(PCpoor[,1]) #16


# Planform Controlled-mod (PC mod) -----------------------------------------------------

PCmod=data%>%
  filter(
    Gradient < 2.5 
    & Confinement!="CV" 
    & (Threads=="Single" | Threads=="Transitional")
    & (Bedform=="Plane-Bed"| Bedform=="Pool-Riffle")  
    & (Sinuosity>1.1 & Sinuosity<1.5) 
    & ((LWfreq>10 & LWfreq<60) | is.na(LWfreq))
  )%>%mutate(RS="PC", Condition="mod")
PCmod
summary(PCmod)
length(PCmod[,1]) #16

#PCmodsum=percAreasummary(PCmod)
#PCmodsum$RScond="PC mod"
#head(PCmodsum)


# Planform Controlled-good (PC good) -----------------------------------------------------
PCgood=data%>%
  filter(
    Gradient < 2.5 
    & Confinement!="CV"
    & (Threads=="Single" | Threads=="Transitional"| Threads=="Multi")
    & Bedform=="Pool-Riffle"
    & (Sinuosity<1.5 & Sinuosity>1.1) 
    &((LWfreq>20) | is.na(LWfreq))
  )%>%mutate(RS="PC", Condition="good")
PCgood
summary(PCgood)
length(PCgood[,1]) #13


#PCgoodsum=percAreasummary(PCgood)
#PCgoodsum$RScond="PC good" 
#head(PCgoodsum)


# Wandering-poor (WA poor) -----------------------------------------------------

WApoor=data%>%
  filter(
    Gradient < 2  
    & Confinement!="CV"
    & Threads=="Single"
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.2
    & (LWfreq < 30 | is.na(LWfreq))
  )%>%mutate(RS="WA", Condition="poor")
WApoor
summary(WApoor)
length(WApoor[,1]) #18


# Wandering-mod (WA mod) -----------------------------------------------------

WAmod=data%>%
  filter(
    Gradient < 2 
    & Confinement!="CV" 
    & (Threads=="Single" | Threads=="Transitional")
    & (Bedform=="Pool-Riffle" | Bedform=="Plane-Bed") 
    & (Sinuosity>1.2 & Sinuosity<1.3) 
  #  & ((LWfreq < 60 & LWfreq>1) | is.na(LWfreq))
    & ((LWfreq < 60) | is.na(LWfreq))
  )%>%mutate(RS="WA", Condition="mod")
WAmod
summary(WAmod)
length(WAmod[,1]) #9


# Wandering-good (WA good) -----------------------------------------------------
WAgood=data%>%
  filter(
    Gradient < 2 
    & Confinement!="CV" 
    & Threads!="Single" 
    & Bedform!="Plane-Bed"
    & (Sinuosity>1.1 & Sinuosity<1.5)
    & ((LWfreq>20) | is.na(LWfreq))
  )%>%mutate(RS="WA", Condition="good")
WAgood
summary(WAgood)
length(WAgood[,1]) #6



# Confined Valley-poor (CV poor) -----------------------------------------------------

CVpoor=data%>%
  filter(
    (Gradient >2 & Gradient <6)
    & Confinement=="CV" 
    & Threads=="Single" 
    & (Bedform=="Plane-Bed"| Bedform=="Rapid") 
    & Sinuosity<1.1
    & ((LWfreq<30) | is.na(LWfreq))
  )%>%mutate(RS="CV", Condition="poor")
CVpoor
summary(CVpoor)
length(CVpoor[,1]) #5



# Confined Valley-mod (CV mod)-----------------------------------------------------
CVmod=data%>%
  filter(
    (Gradient>2 & Gradient<6)
    & Confinement=="CV" 
    & Threads=="Single" 
    & Bedform!="Plane-Bed" 
    & Sinuosity<1.1 
    & ((LWfreq<60) | is.na(LWfreq))
)%>%mutate(RS="CV", Condition="moderate")
CVmod
summary(CVmod)
length(CVmod[,1]) #10



# Confined Valley-(CV good) -----------------------------------------------------

CVgood=data%>%
  filter(
    (Gradient>2 & Gradient<6)
    & Threads!="Multi" 
    & Bedform!="Plane-Bed" 
    & Sinuosity<1.2 
    & Confinement=="CV" 
    & ((LWfreq>10) | is.na(LWfreq))
  )%>%mutate(RS="CV", Condition="good")
CVgood
summary(CVgood)
length(CVgood[,1]) #10
s




#Combining a visit list --------------------



###########################################################
#Combine selectiosn into one dataset and export to .csv
###########################################################

#combine your selections above into one dataset
selections=rbind(FCpoor,FCmod, FCgood, 
                 AFpoor,AFmod, AFgood,
                 PCpoor,PCmod, PCgood, 
                 WApoor, WAmod, WAgood,
                 CVpoor, CVmod, CVgood)%>%
  mutate(RScond=paste(RS, Condition, sep=""))

#prints sample size summary
selections%>%group_by(RS, Condition)%>%count()

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

##specify output directory where you want the Maps to go
OUTdir=paste(INdir, "Maps", sep="\\")
if(file.exists(OUTdir)==F){dir.create(OUTdir)}

##specify variables used in script

layer="Tier3_InChannel"
RScolname="RScond"
idcolname="visit"
idcolname2=NA

#soruce the geomorphic MapsbyRSselection from where it is locally saved.
source(paste(DATAdir, "\\scripts\\MapsbyRSselection.R", sep=""))
       
       
       