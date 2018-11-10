#Copy maps to new directories to quickly verify subsetted data as good representations for desired 
#river style and condition-------------------------------------------------------------


#specify an output directory where the maps will be placed.
GITdir='E:\\GitHub\\GeomorphicUpscale\\ExampleData'
OUTdir='E:\\Box Sync\\ET_AL\\Projects\\USA\\ISEMP\\GeomorphicUnits\\Analyses\\Upscaling\\Maps'
MAPrepo="E:/Box Sync/ET_AL/Projects/USA/ISEMP/GeomorphicUnits/Figs/Maps/GUwithcontour"
 
#read in selections generated from RSselection.R
selections=read.csv(paste(GITdir, "\\Asotinselections.csv", sep=""))
RSlist=levels(selections$RS) #create list of RS and condition variables

i=1
for(i in 1:length(RSlist)){
  RS=RSlist[i]
  RSdir=paste(OUTdir, RS, sep="\\") #create output directory for RS and condition
  dir.create(RSdir) #make folder
  rows=which(selections$RS==RSlist[i]) #vector of rows related to given RS and Condition
  for(i in 1:length(rows)){
    visit=selections$Visit[rows[i]] 
    mapfile=paste(MAPrepo,"/VISIT_",visit,".pdf", sep="")
    if (file.exists(mapfile)){
       file.copy(mapfile, RSdir)} else {print(paste("map for visit", visit, "does not exist", sep=" "))}
  }
}


