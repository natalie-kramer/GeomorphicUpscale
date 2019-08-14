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
PROJdir="E:\\AsotinUpscale" #filepath

#Specify directory path to the downloaded Git Repo
GUPdir="" #filepath

#Read in selections created by RSselections.R
selections.file=""  #filepath

#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

#user defined variables
gu.type=""      #Options: UnitForm, GU #UnitShape not available at this time since I don't have maps of these in the database
RSlevels=c("", "", "", "", "" ) #optional vector argument to set RS factor order in graphs and displays, leave as  NA if alphabetical is desired
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
model=""         	#Options: nrei, fuzzy, NA
species=""         #Options: steelhead, chinook, NA  #I could hardcode this for now..., one less variable.

#source and run code to generate output
source(paste(GUPdir, "\\scripts\\response.reach.R", sep=""))

#source and run code to generate output
source(paste(GUPdir, "\\scripts\\response.unit.R", sep=""))


#####################################
#####Generating Upscale Output#######
#####################################

braid.index.file="" #file path
network.file="" #file path
#Builds the project directory structure and re-organizes inputs
source(paste(GUPdir, "\\scripts\\projbuild.R", sep=""))

responsepool="byRScond" #Options: "byRScond", "byRS", "byAll"
segIDcol="" #user supplied
lengthcol="" #user supplied
widthcol="" #user supplied.
condcols=c("","", "", "") #user supplied, variable length
areacols=NA #user supplied. leave as NA if no area is specified per reach segment and it will be estimated

#source and run code to generate output for upscaling response variabales
source(paste(GUPdir, "\\scripts\\upscale.response.R", sep=""))

#source and run code to generate output for upscaling gu variables (not written yet)
#source(paste(GUPdir, "\\scripts\\upscale.assemblage.R", sep=""))


########################################