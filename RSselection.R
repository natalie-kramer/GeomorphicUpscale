
setwd("E://GitHub//GeomorphicUpscale")
reachdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\ReachMetrics"
GUTdir="E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Data\\Metrics\\GUTMetrics\\GUT2.1Run01"
GITdir='E:\\GitHub\\GeomorphicUpscale'


#This loads in the scrip that summarizes GUT output by unit
load('E:\\GitHub\\GeomorphicUpscale\\UnitSummary.R') #isn't reading in correctly?


#reads in database of reach variables.
data=read.csv(paste(GITdir,list.files(GITdir)[1], sep="\\"))

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

#reads in selection
criteria=read.csv("E://GitHub//GeomorphicUpscale//ExampleData//ReachSelectionCriteria.csv", skip=20)


###########################################################


# Fan Controlled-poor -----------------------------------------------------

criteria


FCpoor=data%>%
  filter((Grad < 3 & Grad>1) & Threads=="Single" & Bedform=="Plane-Bed" & Sin<1.3, Confinement!="UCV" )
FCpoor$RS="FC poor"
levels(as.factor(as.character(FCpoor$Bedform)))

FCpoorsum=percAreasummary(FCpoor)

FCpoorsum$RS="FC poor"
head(FCpoorsum)

# Fan Controlled-mod -----------------------------------------------------


FCmod=data%>%
  filter((Grad < 3 & Grad>1) & Threads=="Single" & Bedform=="Pool-Riffle" & Sin<1.3, Confinement!="UCV"  )
FCmod$RS="FC mod"
levels(as.factor(as.character(FCmod$Bedform)))

FCmodsum=percAreasummary(FCmod)
FCmodsum$RS="FC mod"
head(FCmodsum)

# Fan Controlled-good -----------------------------------------------------

FCgood=data%>%
  filter((Grad < 3 & Grad>1) & Threads!="Multi" & Bedform!="Plane-Bed"& (Sin<1.5 &Sin>1.06) & Confinement!="UCV"  )
levels(as.factor(as.character(FCgood$Bedform)))
FCgood$RS="FC good"

FCgoodsum=percAreasummary(FCgood)
FCgoodsum$RS="FC good"
head(FCgoodsum)



# Alluvial Fan-poor -----------------------------------------------------

AFpoor=data%>%
  filter(Grad < 3  & Threads=="Single" & Bedform=="Plane-Bed" & Sin<1.3)
levels(as.factor(as.character(AFpoor$Bedform)))
AFpoor$RS="AF poor"

AFpoorsum=percAreasummary(AFpoor)

AFpoorsum$RS="AF poor"
head(AFpoorsum)

# Alluvial Fan-mod -----------------------------------------------------


AFmod=data%>%
  filter(Grad < 3 & Threads=="Single" & Bedform=="Pool-Riffle" & Sin<1.3)
levels(as.factor(as.character(AFmod$Bedform)))
AFmod$RS="AF mod"

AFmodsum=percAreasummary(AFmod)
AFmodsum$RS="AF mod"
head(AFmodsum)

# Alluvial Fan-good -----------------------------------------------------

AFgood=data%>%
  filter(Grad < 3 & Threads!="Single" & Bedform!="Plane-Bed"& Sin<1.3)
levels(as.factor(as.character(AFgood$Bedform)))
AFgood$RS="AF good"

AFgoodsum=percAreasummary(AFgood)
AFgoodsum$RS="AF good"
head(AFgoodsum)








# Planform Controlled-poor -----------------------------------------------------

PCpoor=data%>%
  filter(Grad < 2  & Threads=="Single" & Bedform=="Plane-Bed" & Sin<1.3, Confinement!="CV")
levels(as.factor(as.character(PCpoor$Bedform)))
PCpoor$RS="PC poor"

PCpoorsum=percAreasummary(PCpoor)
PCpoorsum$RS="PC poor"
head(PCpoorsum)

# Planform Controlled-mod -----------------------------------------------------


PCmod=data%>%
  filter(Grad < 2 & Threads=="Single" & (Bedform=="Plane-Bed"| Bedform=="Pool-Riffle")  & (Sin>1.06 & Sin<1.5) & Confinement!="CV" )
levels(as.factor(as.character(PCmod$Bedform)))
PCmod$RS="PC mod"

PCmodsum=percAreasummary(PCmod)
PCmodsum$RS="PC mod"
head(PCmodsum)


# Planform Controlled-good -----------------------------------------------------

PCgood=data%>%
  filter(Grad < 2 & Threads!="Multi" & Bedform!="Plane-Bed"& (Sin<1.5 & Sin>1.3) )
levels(as.factor(as.character(PCgood$Bedform)))
PCgood$RS="PC good"  

PCgoodsum=percAreasummary(PCgood)
PCgoodsum$RS="PC good" 
head(PCgoodsum)


# Wandering-poor -----------------------------------------------------

WApoor=data%>%
  filter(Grad < 2  & Threads=="Single" & Bedform=="Plane-Bed" & Sin<1.3, Confinement!="CV")
levels(as.factor(as.character(WApoor$Bedform)))
WApoor$RS="WA poor"

WApoorsum=percAreasummary(WApoor)
WApoorsum$RS="WA poor"
head(WApoorsum)

# Wandering-mod -----------------------------------------------------


WAmod=data%>%
  filter(Grad < 2 & Threads=="Transitional" & (Bedform=="Pool-Riffle") & (Sin>1.06 & Sin<1.5) & Confinement!="CV" )
levels(as.factor(as.character(WAmod$Bedform)))
WAmod$RS="WA mod"

WAmodsum=percAreasummary(WAmod)
WAmodsum$RS="WA mod"
head(WAmodsum)


# Wandering-good -----------------------------------------------------

WAgood=data%>%
  filter(Grad < 2 & Threads!="Single" & Bedform!="Plane-Bed"& (Sin>1.06 & Sin<1.5)& Confinement!="CV" )
levels(as.factor(as.character(WAgood$Bedform)))
WAgood$RS="WA good"  

WAgoodsum=percAreasummary(WAgood)
WAgoodsum$RS="WA good"
head(WAgoodsum)












# Confined with Floodplain Pockets-poor -----------------------------------------------------

CFpoor=data%>%
  filter((Grad >2) & Threads=="Single" & (Bedform=="Plane-Bed"| Bedform=="Rapid") & Sin<1.3, Confinement=="CV" )
CFpoor$RS="CF poor"
levels(as.factor(as.character(CFpoor$Bedform)))

CFpoorsum=percAreasummary(CFpoor)
CFpoorsum$RS="CF poor"
head(CFpoorsum)

# Confined with Floodplain Pockets-mod -----------------------------------------------------

CFmod=data%>%
  filter(Grad>2 & Threads=="Single" &  Bedform!="Plane-Bed" & Sin<1.3 & Confinement=="CV" )
CFmod$RS="CF mod"
levels(as.factor(as.character(CFmod$Bedform)))

CFmodsum=percAreasummary(CFmod)
CFmodsum$RS="CF mod"
head(CFmodsum)

# Confined with Floodplain Pockets-mod -----------------------------------------------------

CFgood=data%>%
  filter(Grad >2 & Threads!="Multi" & Bedform!="Plane-Bed"& (Sin<1.5 &Sin>1.06) & Confinement=="CV"  )
levels(as.factor(as.character(CFgood$Bedform)))
CFgood$RS="CF good"

CFgoodsum=percAreasummary(CFgood)
CFgoodsum$RS="CF good"
head(CFgoodsum)







# Confined with Bedrock-poor -----------------------------------------------------

CBpoor=data%>%
  filter((Grad >3) & Threads=="Single" & (Bedform=="Plane-Bed"| Bedform=="Rapid"| Bedform=="Cascade") & Sin<1.3, Confinement=="CV" )
CBpoor$RS="CB poor"
levels(as.factor(as.character(CBpoor$Bedform)))

CBpoorsum=percAreasummary(CBpoor)
CBpoorsum$RS="CB poor"
head(CBpoorsum)

# Confined with Bedrock-mod -----------------------------------------------------

CBmod=data%>%
  filter(Grad>3 & Threads=="Single" &  (Bedform!="Plane-Bed"& Bedform!="Step-Pool") & Sin<1.3 & Confinement=="CV" )
CBmod$RS="CB mod"
levels(as.factor(as.character(CBmod$Bedform)))

CBmodsum=percAreasummary(CBmod)
CBmodsum$RS="CB mod"
head(CBmodsum)

# Confined with Bedrock-good -----------------------------------------------------

CBgood=data%>%
  filter(Grad>3 & Threads=="Single" &  (Bedform!="Plane-Bed") & Sin<1.3 & Confinement=="CV" )
levels(as.factor(as.character(CBgood$Bedform)))
CBgood$RS="CB good"

CBgoodsum=percAreasummary(CBgood)
CBgoodsum$RS="CB good"
head(CBgoodsum)


