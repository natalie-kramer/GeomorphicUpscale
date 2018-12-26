#Copy maps to new directories to quickly verify subsetted data as good representations for desired 
#river style and condition-------------------------------------------------------------

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Nov 16, 2018


#Function
#MapsbyRSselection=function(selections,  OUTdir, Maprepo, layer="Tier3_InChannel", RScolname="RScond", idcolname="Visit", idcolname2=NA){
 

 MAPrepo=paste(DATAdir, "\\Maps", sep="")  
  RScolname="RScond" 
  idcolname="visit"
  idcolname2=NA

  INdir=paste(PROJdir, "Inputs", sep="\\")
  if (file.exists(INdir)==F){dir.create(INdir)}
  
  RScol=which(colnames(selections)==RScolname)
  idcol=which(colnames(selections)==idcolname)
  if(is.na(idcolname2)==F){
  idcol2=which(colnames(selections)==idcolname2)}
  
  RSlist=levels(selections[,RScol]) #create list of RS 
  print("RSlist")
  print(RSlist)
  
  maplist=paste(MAPrepo,list.files(MAPrepo)[grep(layer, list.files(MAPrepo))],sep="\\")#list of files in MAPrepo
  
  Mapdir=paste(INdir, "Maps", sep="\\")
  if (file.exists(Mapdir)==F){dir.create(Mapdir)} #Map map output Dir if it doesn't exist already
  if (file.exists(Mapdir)==T){
    if (file.exists(paste(Mapdir,layer,sep="\\"))==F){
      dir.create(paste(Mapdir,layer,sep="\\"))
    }
    if (file.exists(paste(Mapdir,layer,sep="\\"))==T){
      unlink(paste(Mapdir,layer,sep="\\"), recursive=T)
      dir.create(paste(Mapdir,layer,sep="\\"))
    }
  }
  
  i=1
  for(i in 1:length(RSlist)){
    RS=RSlist[i]
    RSdir=paste(Mapdir, layer, RS, sep="\\") #create output directory for RS and condition
    if (file.exists(RSdir)==F){dir.create(RSdir)}  #make folder corresponding to RS and condition if it doesnt exist already
    
    rows=which(selections[,RScol]==RSlist[i]) #vector of rows related to given RS and Condition
    for(i in 1:length(rows)){
      ID=selections[rows[i],idcol] 
      mapfile=maplist[grep( paste("_",as.character(ID),"_",sep="") , maplist)]
      if(file.exists(mapfile)){
        file.copy(mapfile, RSdir, overwrite=T)} else {print(paste("map for", ID, "does not exist", sep=" "))
        }
    }
  }
  
  rm(list=c(  "i"     ,     "ID"      ,   "idcol"   ,   "idcolname" , "idcolname2", "INdir" , "Mapdir",    
 "mapfile" ,   "maplist"  ,  "MAPrepo"  ,  "rows"  ,     "RS"   ,      "RScol"  ,    "RScolname" , "RSdir",      "RSlist"   ) ) 
  
 #keepvars=c("criteria", "selections", "PROJdir","plottype", "DATAdir", "makeplot", "network", "layer")
  #keep=match(x = keepvars, table = ls())
  #ls()[-keep]
  #vars
  
  #removing intermediate variables
  #dnrm <- function(vars, envir = .GlobalEnv) { 
  #  vars <- c(vars, "dnrm") 
  #  keep <- match(x = vars, table = ls(envir=envir)) 
  #  if(any(is.na(keep))) { 
  #    stop(paste("Some of the variables were not found in", 
  #               environmentName(envir))) 
  #  } 
  #  rm(list = ls(envir = envir)[-keep], envir = envir) 
  #  cat("Removed all but", length(keep), "objects from", 
  #      environmentName(envir), fill = TRUE) 
  #} 
  
  #dnrm(c("criteria", "DATAdir", "layer", "makeplot", "network", "plottype", "PROJdir", "selections"))
    #In case you need two columns to define the unique mapfile
    #if(is.na(idcolname2)==F){
    #  ID2=selections[rows[i],idcol]
    #  mapfile=maplist[grep( paste(ID,ID2, sep="_") , maplist)]
    #  if (file.exists(mapfile)){
     #   file.copy(mapfile, RSdir)} else {print(paste("map for", ID, ID2, "does not exist", sep=" "))
     #   }
    #}
#  } 
#}

###################
#####Variables
##################
##selections: input csv that has columns identifying the riverstyle type/condition as well as another column or columns that
#uniquely identify specific sites. Basically the output from RSselection sourced from "E:\\GitHub\\GeomorphicUpscale\\Scripts\\RSselection.R"
##OUTdir: the directory where you want the function to past the images 
##Maprepo: the local directory path to the map repository sourced from "E:\\GitHub\\GeomorphicUpscale\\Database\\Maps.zip"
##layer: the GUT layer that you want to copy over (Tier2, Tier3, Tier2_Transitions). The text stream here should be included in the map name in the repo
##RScolname: the name of the column where the RiverStyle condition variable is.  Default is 'RS'
##idcolname:  the name of the column where a unique identifier also contained in the map name is located. Default is "Visit"
##idcolname2: the name of a second column where a unique identifier that is also contained in the map name is located. Default is "NA"
##################

###################
## Runs most easily when maps in repo are named in convention of "E:\\GitHub\\pyGUT\\SupportingTools\\makeGUTmaps.R" 
##and selections table is in format returned by use of "E:\\GitHub\\GeomorphicUpscale\\Scripts\\RSselection.R"
##################


###################
#####Example Usage
##################

##specify an output directory where the maps will be placed.
#OUTdir='E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Analyses\\Upscaling\\Maps'
#OUTdir='E:\\PantherUpscale\\Outputs\\Maps'

##Specify where the database map directory is
#MAPrepo="E:\\GitHub\\GeomorphicUpscale\\Database\\Maps"

##read in selections generated from RSselection.R
#selections=read.csv("E:\\GitHub\\GeomorphicUpscale\\ExampleData\\Asotinselections.csv")
#selections=read.csv("E:\\PantherUpscale\\Inputs\\Pantherselections.csv")

#MapsbyRSselection(selections, OUTdir, MAPrepo, layer="Tier3_InChannel", RScolname="RScond" ,idcolname="visit")
##################
