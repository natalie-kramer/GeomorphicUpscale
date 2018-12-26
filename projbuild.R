
#This script Builds the project directory

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Dec 7, 2018


#Name your project
PROJname="AsotinExampleData"

#Specify where on your computer you want your project directory
PROJloc='E:\\GitHub\\GeomorphicUpscale' 

#Local location of user defined geo indicater RS selection criterias
criteriafile="E://GitHub//GeomorphicUpscale//ExampleData//AsotinReachSelectionCriteria.csv"

#Add copy of Selection file to Inputs.


###RUN THE STUFF BELOW.

#sets up project directory
PROJdir=paste(PROJloc, PROJname, sep="\\")
if (file.exists(PROJdir)==F){dir.create(PROJdir)}


#Sets up local input folder
INdir=paste(PROJdir, "Inputs", sep="\\")
if (file.exists(INdir)==F){dir.create(INdir)}

#Copy criteria file to input if it isn't already there
if (file.exists(paste(INdir,criteriafile,sep="\\"))==F){
  copy.file(criteriafile, INdir)
  
  split_path <- function(path) {
    if (dirname(path) %in% c(".", path)) return(basename(path))
    return(c(basename(path), split_path(dirname(path))))
  }
  criteriafile=paste(INdir,split_path(criteriafile)[1], sep="\\")}

