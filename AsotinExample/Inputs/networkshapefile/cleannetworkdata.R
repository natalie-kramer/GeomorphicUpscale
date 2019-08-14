INdir="E:\\AsotinUpscale\\Inputs\\networkshapefile\\networkshapefile"

library(rgdal)
library(tidyr)
library(dplyr)

###fixing up network data####
network.sp=readOGR(paste(INdir,'\\AGA_Management_upscalingcapacity.shp', sep=""))
network.sp@data$RS=as.character(network.sp@data$RS)
network.sp@data$RS[which(startsWith(as.character(network.sp@data$RS),"C")==T)]="CV"

#combines all different CV types into one River Style, "CV"
network.sp@data$RScurrent=gsub("CF","CV",network.sp@data$RScurrent)
network.sp@data$RScurrent=gsub("CB","CV",network.sp@data$RScurrent)
network.sp@data$RScurrent=gsub("CH","CV",network.sp@data$RScurrent)
network.sp@data$RSrestored=gsub("CF","CV",network.sp@data$RSrestored)
network.sp@data$RSrestored=gsub("CB","CV",network.sp@data$RSrestored)
network.sp@data$RSrestored=gsub("CH","CV",network.sp@data$RSrestored)

#sets changes "moderate" condition to "mod"
network.sp@data$RScurrent=gsub("moderate","mod",network.sp@data$RScurrent)
network.sp@data$RSrestored=gsub("moderate","mod",network.sp@data$RSrestored)
as.factor(network.sp@data$RScurrent)

#cleans up scenarios
#Condition1=up one condition if it RecPot != LOW
#Condition2=good if RecPot==High, up one if RecPot="Moderate, stays same if Rec. Pot==Mod
#Condition3=all good.
network.sp@data=extract(network.sp@data, RScurrent, into = c("Condition0"), "([:lower:].*)", remove=F)%>%
  extract(RSrestored, into = c("Condition1"), "([:lower:].*)", remove=F)%>%
  extract(RSrestored, into = c("Condition2"), "([:lower:].*)", remove=F)%>%
  
  mutate(Condition2=replace(Condition2, RecPotent=="High Recovery Potential", "good"))%>%
  mutate(Condition3="good")


network.sp@data%>%filter(RecPotent=="Low Recovery Potential")
network.sp@data%>%filter(RecPotent=="Moderate Recovery Potential")
network.sp@data%>%filter(RecPotent=="High Recovery Potential")

names(network.sp@data)
network=network.sp@data[,c(3,7,28:29,37,31,33,36,35,38)]%>%rename("bf.width.m"=BFWest  , "length.m"=Length_m)



write.csv(network, paste(INdir,"network.csv", sep="\\"), row.names=F )
