
#This script uses information within ReachSelectionCriteria.csv to select reaches within the GUT database
#that match geomorphically to specified geomorphic indicator characteristics. 

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Oct 25, 2018



#Reading in functions and data
setwd("E://GitHub//GeomorphicUpscale")

#sets directories where GUT oututs and summaries reside
reachdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\ReachMetrics"
GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"

GITdir='E:\\GitHub\\GeomorphicUpscale\\ExampleData'

#Set directory where you want the output selections to go
OUTdir='E:\\GitHub\\GeomorphicUpscale\\ExampleData'

#This loads in the scrip that summarizes NREI or HSI output by unit contains function unitsummary()
#For some reason it isn't loading. Need to fix.


#reads in database of reach variables.
data1=read.csv("E://GitHub//GeomorphicUpscale//ExampleData//Database_reachcharacteristics.csv")



#I am pretty sure I don't need the stuff below, I was just adding a new column and copin it over...
#poor=which(data$Geo_Cond=="poor")
#mod=which(data$Geo_Cond=="moderate")
#good=which(data$Geo_Cond=="good")
#intact=which(data$Geo_Cond=="intact")

#data$Condition=NA
#data[poor,]$Condition="poor"
#data[mod,]$Condition="good"
#data[intact,]$Condition="intact"
#data[good,]$Condition="moderate"
#data$Condition=as.factor(data$Condition)

#reads in selection criterion
criteria=read.csv("E://GitHub//GeomorphicUpscale//ExampleData//AsotinReachSelectionCriteria.csv", skip=20)

###########################################################
#Dependencies
###########################################################
load('E:\\GitHub\\GeomorphicUpscale\\UnitSummary.R') #isn't reading in correctly?
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
# Fan Controlled-poor (FC poor) -----------------------------------------------------
criteria[1,]
FCpoor=data%>%
  filter((Gradient < 3.5 & Gradient>1) 
         & Threads=="Single" 
         & Bedform=="Plane-Bed" 
         & Sinuosity<1.1 
         & Confinement!="UCV" 
        & (LWfreq < 30 | is.na(LWfreq))
        
)
FCpoor$RS="FCpoor"
FCpoor


#Use in next script...
#levels(as.factor(as.character(FCpoor$Bedform)))

#FCpoorsum=percAreasummary(FCpoor)

#FCpoorsum$RS="FC poor"
#head(FCpoorsum)

# Fan Controlled-mod (FC mod)-----------------------------------------------------

criteria[2,]
FCmod=data%>%
  filter(
        (Gradient < 3.5 & Gradient>1) 
         & Threads=="Single" 
         & (Bedform=="Plane-Bed"| Bedform=="Pool-Riffle")  
         & (Sinuosity<1.3 & Sinuosity>1.04) 
         & Confinement!="UCV"  
         & (LWfreq < 60  | is.na(LWfreq))
)
FCmod$RS="FCmod"
FCmod

#levels(as.factor(as.character(FCmod$Bedform)))
#FCmodsum=percAreasummary(FCmod)
#FCmodsum$RS="FC mod"
#head(FCmodsum)

# Fan Controlled-good (FC good) -----------------------------------------------------
criteria[3,]
FCgood=data%>%
  filter(
        (Gradient < 3.5 & Gradient>1) 
         & Threads!="Multi" 
         & Bedform!="Plane-Bed"
         & (Sinuosity<1.5 & Sinuosity>1.1) 
         & Confinement!="UCV" 
        #& (LWfreq > 10 | is.na(LWfreq))
        )
FCgood$RS="FCgood"
FCgood

#FCgoodsum=percAreasummary(FCgood)
#FCgoodsum$RS="FC good"
#head(FCgoodsum)



# Fan Controlled-intact (FC intact)----------------------------------------------
  criteria[4,]
FCintact=data%>%
  filter((Gradient < 3.5 & Gradient>1) 
         & Threads!="Multi" 
         & Bedform!="Plane-Bed"
         & (Sinuosity<1.5 & Sinuosity>1.1 )
         & Confinement!="UCV"  
        & (LWfreq > 40  | is.na(LWfreq))
        )
FCintact$RS="FCintact"
FCintact




# Alluvial Fan-poor (AF poor) -----------------------------------------------------
criteria[5,]
AFpoor=data%>%
  filter(
        Gradient < 3  
         & Threads=="Single" 
         & Bedform=="Plane-Bed" 
         & Sinuosity<1.2
        & Confinement!="CV"  
        & (LWfreq < 30 | is.na(LWfreq))
        )
AFpoor$RS="AFpoor"
AFpoor


#AFpoorsum=percAreasummary(AFpoor)

#AFpoorsum$RS="AF poor"
#head(AFpoorsum)

# Alluvial Fan-mod (AF mod) -----------------------------------------------------

criteria[6,]
AFmod=data%>%
  filter(
    Gradient < 3 
    & (Threads=="Single" | Threads=="Transitional")
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.3
    & Confinement!="CV"  
    & ((LWfreq < 60 & LWfreq > 10)| is.na(LWfreq))
  )
AFmod$RS="AFmod"
AFmod

#AFmodsum=percAreasummary(AFmod)
#AFmodsum$RS="AF mod"
#head(AFmodsum)

# Alluvial Fan-good (AF good) -----------------------------------------------------
criteria[7,]
AFgood=data%>%
  filter(
    Gradient < 3 
    & (Threads=="Single" | Threads=="Transitional" | Threads=="Multi")
    & (Braid < 5)
    & (Bedform=="Plane-Bed" | Bedform=="Pool-Riffle")
    & (Sinuosity<1.5 & Sinuosity >1.1)
    & Confinement!="CV" 
    & (LWfreq > 20| is.na(LWfreq))
)
AFgood$RS="AFgood"
AFgood

#AFgoodsum=percAreasummary(AFgood)
#AFgoodsum$RS="AF good"
#head(AFgoodsum)


# Alluvial Fan-good (AF intact) -----------------------------------------------------
criteria[8,]
AFintact=data%>%
  filter(
    Gradient < 3 
    & (Threads=="Single" | Threads=="Transitional"| Threads=="Multi")
    #& (Braid < 5)
    & (Bedform=="Plane-Bed" | Bedform=="Pool-Riffle")
    & (Sinuosity<1.5 & Sinuosity >1.1)
    & Confinement!="CV" 
    & (LWfreq > 40| is.na(LWfreq))
  )
AFintact$RS="AFintact"
AFintact





# Planform Controlled-poor (PC poor) -----------------------------------------------------
criteria[9,]
PCpoor=data%>%
  filter(
          Gradient < 2.5  
         & Threads=="Single" 
         & Bedform=="Plane-Bed" 
         & Sinuosity<1.1 
         & Confinement!="CV"
         & (LWfreq<30| is.na(LWfreq))
         )
PCpoor$RS="PCpoor"
PCpoor



# Planform Controlled-mod (PC mod) -----------------------------------------------------

criteria[10,]
PCmod=data%>%
  filter(
        Gradient < 2.5 
         & (Threads=="Single" | Threads=="Transitional")
         & Braid<1.2
         & (Bedform=="Plane-Bed"| Bedform=="Pool-Riffle")  
         & (Sinuosity>1.1 & Sinuosity<1.5) 
         & Confinement!="CV" 
         & ((LWfreq>5 & LWfreq<60) | is.na(LWfreq))
         )
PCmod$RS="PCmod"
PCmod

#PCmodsum=percAreasummary(PCmod)
#PCmodsum$RS="PC mod"
#head(PCmodsum)


# Planform Controlled-good (PC good) -----------------------------------------------------
criteria[11,]
PCgood=data%>%
  filter(
    Gradient < 2.5 
    & Threads!="Multi" 
    & Bedform=="Pool-Riffle"
    & (Sinuosity<1.5 & Sinuosity>1.1) 
    & Confinement!="CV"
    &((LWfreq>10 & LWfreq<100) | is.na(LWfreq))
    )
PCgood$RS="PCgood" 
PCgood

#PCgoodsum=percAreasummary(PCgood)
#PCgoodsum$RS="PC good" 
#head(PCgoodsum)
# Planform Controlled-good (PC intact) -----------------------------------------------------

criteria[12,]
PCintact=data%>%
  filter(
    Gradient < 2.5 
    & Threads!="Single" 
    & Bedform!="Plane-Bed"
    & (Sinuosity<1.5 & Sinuosity>1.1) 
    & Confinement!="CV"
    &((LWfreq>40) | is.na(LWfreq))
  )
PCintact$RS="PCintact" 
PCintact

# Wandering-poor (WA poor) -----------------------------------------------------

criteria[13,]
WApoor=data%>%
  filter(
    Gradient < 2  
    & Threads=="Single"
    & Bedform=="Plane-Bed" 
    & Sinuosity<1.2
    & Confinement!="CV"
    & (LWfreq < 30 | is.na(LWfreq))
    
  )
WApoor$RS="WApoor"
WApoor

#WApoorsum=percAreasummary(WApoor)
#WApoorsum$RS="WA poor"
#head(WApoorsum)

# Wandering-mod (WA mod) -----------------------------------------------------

criteria[14,]
WAmod=data%>%
  filter(
    Gradient < 2 
    & (Threads=="Single" | Threads=="Transitional")
    & Braid<1.5
    & (Bedform=="Pool-Riffle" | Bedform=="Plane-Bed") 
    & (Sinuosity>1.2 & Sinuosity<1.3) 
    & Confinement!="CV" 
    & ((LWfreq < 60 & LWfreq>1) | is.na(LWfreq))
)
WAmod$RS="WAmod"
WAmod

#WAmodsum=percAreasummary(WAmod)
#WAmodsum$RS="WA mod"
#head(WAmodsum)


# Wandering-good (WA good) -----------------------------------------------------
criteria[15,]
WAgood=data%>%
  filter(
    Gradient < 2 
    & Threads!="Single" 
    & Bedform!="Plane-Bed"
    & (Sinuosity>1.1 & Sinuosity<1.5)
    & Confinement!="CV" 
    & ((LWfreq>20) | is.na(LWfreq))
)
WAgood$RS="WAgood"
WAgood

#WAgoodsum=percAreasummary(WAgood)
#WAgoodsum$RS="WA good"
#head(WAgoodsum)
# Wandering-intact (WA intact) -----------------------------------------------------
criteria[16,]
WAintact=data%>%
  filter(
    Gradient < 2 
    & Threads=="Multi" 
    & Bedform!="Plane-Bed"
    & (Sinuosity>1.1)
    & Confinement!="CV" 
    & ((LWfreq>40) | is.na(LWfreq))
  )
WAintact$RS="WAintact"
WAintact











# Confined Valley-poor (CV poor) -----------------------------------------------------
criteria[17,]
CVpoor=data%>%
  filter(
    (Gradient >2 & Gradient <6) 
    & Threads=="Single" 
    & (Bedform=="Plane-Bed"| Bedform=="Rapid") 
    & Sinuosity<1.1
    & Confinement=="CV" 
    )
CVpoor$RS="CVpoor"
CVpoor



# Confined Valley-mod (CV mod)-----------------------------------------------------
criteria[18,]
CVmod=data%>%
  filter(
    (Gradient>2 & Gradient<6)
    & Threads=="Single" 
    &  Bedform!="Plane-Bed" 
    & Sinuosity<1.1 
    & Confinement=="CV" )
CVmod$RS="CVmod"
CVmod



# Confined Valley-(CV good) -----------------------------------------------------

criteria[19,]
CVgood=data%>%
  filter(
    (Gradient>2 & Gradient<6)
    & Threads!="Multi" 
    & Bedform!="Plane-Bed" 
    & Sinuosity<1.2 
    & Confinement=="CV" 
  )
CVgood$RS="CVgood"
CVgood

# Confined Valley-(CV intact) -----------------------------------------------------

criteria[20,]
CVintact=data%>%
  filter(
    (Gradient>2 & Gradient<6)
    & Threads!="Multi" 
    & Bedform!="Plane-Bed" 
    & Sinuosity<1.3 
    & Confinement=="CV" 
  )
CVintact$RS="CVintact"
CVintact














#Combining a visit list --------------------
#make a list of all possible river styles and conditions 


#combine your selections above into one dataset
selections=rbind(FCpoor,FCmod, FCgood, FCintact,
                 AFpoor,AFmod, AFgood, AFintact,
                 PCpoor,PCmod, PCgood, PCintact,
                 CVpoor, CVmod, CVgood, CVintact)

write.csv(selections, paste(OUTdir, "\\Asotinselections.csv", sep=""))



CBgoodsum=percAreasummary(CBgood)
CBgoodsum$RS="CB good"
head(CBgoodsum)

PCpoorsum=percAreasummary(PCpoor)
PCpoorsum$RS="PC poor"
head(PCpoorsum)

#CFpoorsum=percAreasummary(CFpoor)
#CFpoorsum$RS="CF poor"
#head(CFpoorsum)

CFmodsum=percAreasummary(CFmod)
CFmodsum$RS="CF mod"
head(CFmodsum)
