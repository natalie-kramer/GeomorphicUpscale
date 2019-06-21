#This script Runs the upscale with user defined inputs
#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated JUne 4, 2019

#documentation is provided here:
# https://github.com/natalie-kramer/GeomorphicUpscale/edit/master/docs/upscaling.md

###################################
####User Defined Inputs############
##################################


PROJdir="" #path to your project directory
GUPdir=" " #path to the GeomorphicUpscale repository"

braid.index=" " ##path to braid.index.csv
selections=" " ##path to selections.csv" 
network=" " ##path to network.csv"

#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

#check data
head(network)
head(braid.index)
head(network)

#####################################
####User Defined Variables############
#####################################
#These are set to some defaults.  Please see documentation for options.
#https://natalie-kramer.github.io/GeomorphicUpscale/upscaling.html

layer="Tier2_InChannel_Transition" 
gu.type="UnitForm"  #Also: UnitShape, #GU #UnitForm
makeplot=T				
plottype=".tiff"

#response.R script is not updated to new data format yet
#model="nrei" 	
#species="steelhead"
#lifestage="juvenile"
#responsevar="density"
#ROI="bf"   	
#poolby="none"	
	
#upscale.R script is not updated to new data format yet
#upscalevar="Capacity"
#method="bfDensity"
#segIDcol="segmentID"
#lengthcol="length.m"
#widthcol="bf.width.m"
#condcols=c("Condition0","Condition1", "Condition2")
#RScol="RS"			
#validatenetwork=F

############################################
######Geenerate Estimates and run the Upscale
############################################

######Generating Assemblage Estimates##
source(paste(GUPdir, "\\scripts\\assemblage.R", sep=""))


######Generating Response Files########
#This SCRIPT DOES NOT YET MATCH NEW DATA FORMAT
source(paste(GUPdir, "\\scripts\\response.R", sep=""))

######Generating Upscale Files########
#This SCRIPT DOES NOT YET MATCH NEW DATA FORMAT
#source(paste(GUPdir, "\\scripts\\upscale.R", sep=""))


########################################