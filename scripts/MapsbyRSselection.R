#Copy maps to new directories to quickly verify subsetted data as good representations for desired 
#river style and condition-------------------------------------------------------------

#Natalie Kramer (n.kramer.anderson@gmail.com)
#Last Updated Nov 16, 2018


#Function
#MapsbyRSselection=function(selections,  OUTdir, Maprepo, layer="Tier3_InChannel", RScolname="RScond", idcolname="Visit", idcolname2=NA){
 

 MAPrepo=paste(DATAdir, "\\Database\\Maps", sep="")  
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
  
  maplist=paste(MAPrepo,
                list.files(MAPrepo)[grep(layer, list.files(MAPrepo))],sep="\\")#list of files in MAPrepo
  
  
  #call in custom function to create subdirectories
  source(paste(DATAdir,"\\scripts\\create.subdirs.func", sep=""))
  create.subdirs(INdir, c("Maps",layer))
  Mapdir=paste(INdir, "\\Maps\\", layer,sep="")

  #loops down list of riverstyles and copies relevent visit maps from Map Repo
  i=1
  for(i in 1:length(RSlist)){
    RS=RSlist[i]
    RSdir=paste(Mapdir, RS, sep="\\") #create output directory for RS and condition
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
#OUTdir='...MYPROJECT\\Inputs\\Maps'

##Specify where the database map directory is
#MAPrepo="...\\GeomorphicUpscale\\Database\\Maps"

##read in selections generated from RSselection.R
#selections=read.csv("...MyProject\\inputs\\selections.csv")

#MapsbyRSselection(selections, OUTdir, MAPrepo, layer="Tier3_InChannel", RScolname="RScond" ,idcolname="visit")
##################
