#This script Runs the upscale with user defined inputs
#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated JUne 4, 2019

###################################
####User Defined Inputs############
##################################

PROJdir="E:\\AsotinUpscale"
GUPdir="E:\\GitHub\\GeomorphicUpscale"

braid.index="E://AsotinUpscale//Inputs//braid_index.csv"
selections="E://AsotinUpscale//Inputs//selections.csv" 
network="E://AsotinUpscale//Inputs//network.csv"

#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

#check data
head(network)
head(braid.index)
head(network)

#####################################
####User Defined Variables############
#####################################

####Description of User	Variables#####		
#
#layer: Specifies which GUT output 
#	      #Options: "Tier3_InChannel", "Tier2_InChannel_Transition" 
#model: Specifies which response model
#	      #Options "NREI", "HSI"  #*Currently only available for Steelhead
#ROI: Specifies you region of interest as bankfull (bf), hydro modelling extent (hydro), or extent of fish bearing modelling values (hab)
#	      #Options "bf", "hydro", "hab"
#responsevar: Specifies your response type as total count of fish (No.Fish), # Fish/ROI area in m2 (Density), % of BF area with fish bearing modelling values (Hab),Median Modelling Value witin bf extent (MedModelVal)						
#	      #Options "No.Fish", "Density", "Hab", "MedModelVal"
#poolby: Specifies how you want to average responses: over the entire dataset (none), pooling by river styles (RS) or pooling by each river style and condition varient (RSCond)
#	      #Options: "RS", "RScond", "none" 
#plottype: Specifies format of file extension for plots. If none, they won't be saved to a folder.
#	      #Optinos: #".tiff", ".png", ".pdf", "none"
#segmentID: column header name for reach segment ID in network input file
#distcol: column header name for length of segment in m in network input file
#bfwcol: column header name for estimates of bankful width in network input file
#condcols: vector of column headers for condition scenarios in network input file
#		   #e.g. c("Condition0","Condition1", "Condition2")
#RScol: column header name for RiverStyle code in network input file. 
#	    #Should match river style codes provided in selections file.
########################################

layer="Tier3_InChannel"
makeplot=T				
plottype=".tiff"

model="NREI" 				
ROI="bf"   					
responsevar="Density" 			 
poolby="RScond"	
	
upscalevar="Capacity"
method="bfDensity"
segIDcol="segmentID"
distcol="Length_m"
bfwcol="BFWest"
condcols=c("Condition0","Condition1", "Condition2")
RScol="RS"			
validatenetwork=F

###########################################
##########################################

############################################
######Geenerate Estimates and run the Upscale
############################################

######Generating Assemblage Estimates##
source(paste(GUPdir, "\\scripts\\assemblage.R", sep=""))

######Generating Response Files########
source(paste(GUPdir, "\\scripts\\response.R", sep=""))

######Generating Upscale Files########
source(paste(GUPdir, "\\scripts\\upscale.R", sep=""))


########################################