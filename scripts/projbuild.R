
#This script Builds the project directory

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated JUne 4, 2019

DATAdir=paste(GUPdir, "\\Database", sep="")

if(file.exists(PROJdir)==F){dir.create(PROJdir)}
if(file.exists(DATAdir)==F){print(paste("Database not found, check" , GUPdir,
                                        "for presence of Database subfolder", sep=" "))}

#Sets up local input folder
INdir=paste(PROJdir, "Inputs", sep="\\")
if (file.exists(INdir)==F){dir.create(INdir)}


#copy file to INdir and respecify variablepath
copy.read.func=function(file){
  split_path <- function(path) {
    if (dirname(path) %in% c(".", path)) return(basename(path))
    return(c(basename(path), split_path(dirname(path))))
  }
  
  if (file.exists(paste(INdir,split_path(file)[1],sep="\\"))==F){
  file.copy(from=file, to=INdir)
  newfileloc=paste(INdir,split_path(file)[1], sep="\\")
  data=read.csv(newfileloc)
  }else{data=read.csv(file)}
  return(data)
}
  
#copies over network, selections and braid.index to Inputs folder
#if they didn't already exist there

if(file.exists(braid.index)==T){
braid.index=copy.read.func(braid.index)}else{print("braid.index not found")}

if(file.exists(network)==T){
network=copy.read.func(network)}else{print("network not found")}

if(file.exists(selections)==T){
selections=copy.read.func(selections)}else{print("selections not found")}
