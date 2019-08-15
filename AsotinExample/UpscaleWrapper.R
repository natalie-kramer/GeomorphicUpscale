#This script Runs the upscale with user defined inputs
#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated JUne 4, 2019

#documentation is provided here:
# https://github.com/natalie-kramer/GeomorphicUpscale/edit/master/docs/upscaling.md

###################################
####User Defined Inputs############
##################################

#specify directory path to your project where you want your outputs to go.
#Make a folder if it doesn't already existy
PROJdir="E:\\AsotinUpscale"

#Specify directory path to the downloaded Git Repo
GUPdir="E:\\GitHub\\GeomorphicUpscale"

#Read in selections created by RSselections.R
selections.file="E://AsotinUpscale//Inputs//selections.csv" 

#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

#user defined variables
gu.type="UnitForm"      #Options: UnitForm, GU #UnitShape not available at this time since I don't have maps of these in the database
RSlevels=c("CV", "FC", "PC", "AF", "WA") #optional vector argument to set RS factor order in graphs and displays, leave as  NA if alphabetical is desired
plottype=".pdf"   #Options: .tiff, .png, .pdf, "none"
myscales="fixed" #Options: fixed or free x/y axis scales for tiled plot output

#####################################
####Generating Selection Output######
#####################################

#source the geoindicator summary script
source(paste(GUPdir, "\\scripts\\selection.geoindicators.R", sep="")) 

#soruce the code to copy and file the maps
source(paste(GUPdir, "\\scripts\\selection.maps.R", sep="")) 

#####################################
####Generating Assemblage Output##### #plots are not printing????
#####################################

#source and run code to generate output per reach
source(paste(GUPdir, "\\scripts\\assemblage.reach.R", sep=""))

#source and run code to generate output per unit type
source(paste(GUPdir, "\\scripts\\assemblage.unit.R", sep=""))

#####################################
#####Generating Response Output######
#####################################

#user defined variables
model="nrei"         	#Options: nrei, fuzzy, NA
species="steelhead"         #Options: steelhead, chinook, NA  #I could hardcode this for now..., one less variable.

#source and run code to generate output
source(paste(GUPdir, "\\scripts\\response.reach.R", sep=""))

#source and run code to generate output
source(paste(GUPdir, "\\scripts\\response.unit.R", sep=""))


#####################################
#####Generating Upscale Output#######
#####################################

braid.index.file="E://AsotinUpscale//Inputs//braid_index.csv"
network.file="E://AsotinUpscale//Inputs//network.csv"
#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

responsepool="byRScond" #Options: "byRScond", "byRS", "byAll"
segIDcol="segmentID" #user supplied
lengthcol="length.m" #user supplied
widthcol="bf.width.m" #user supplied.
condcols=c("Condition0","Condition1", "Condition2", "Condition3") #user supplied
areacols=NA #user supplied. leave as NA if no area is specified per reach segment and it will be estimated

#source and run code to generate output for upscaling response variabales
source(paste(GUPdir, "\\scripts\\upscale.response.R", sep=""))



########################################