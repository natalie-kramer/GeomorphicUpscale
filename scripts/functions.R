#creates subdirectories in specified Parent directory based on vector of characters specified by daughters
create.subdirs=function(Parentdir, daughters){
  for(i in 1:length(daughters)){
    #print(Parentdir)
    if (file.exists(Parentdir) == F) {
      dir.create(Parentdir)
      Parentdir = paste(Parentdir, daughters[i], sep = "//")
    } else {Parentdir = paste(Parentdir, daughters[i], sep = "//")}
  }
  if (file.exists(Parentdir) == F){dir.create(Parentdir)
    #print(Parentdir)
  }
  return(Parentdir)
}

#joins selections RS, COndition and visit.id fields with other data.
join.selection=function(selections, joindata){
  #make attribute field of RScond (RS + Condition)
  selections=selections%>%mutate(RScond=paste(RS, Condition, sep=""))
  #create list of RScond to loop over
  RSlist=levels(as.factor(selections$RScond))
  
  #joining in loop over RScond
  for(i in 1:length(RSlist)){
    subdata1=filter(selections, RScond==RSlist[i])%>%
      select(RS, Condition, visit.id)%>%
      left_join(joindata, by="visit.id")
    if(i==1){joindata2=subdata1}else{joindata2=rbind(joindata2,subdata1)}
  }
  
  return(joindata2)
}

#summarizes data by one field.  Tibble should be grouped before hand if you want the summary by group.
summarize.f=function(data, value){
  data1=data%>%
    summarize(avg=mean(value, na.rm=T), 
              sd=sd(value, na.rm=T),
              med=median(value, na.rm=T), 
              min=min(value, na.rm=T) ,
              max=max(value, na.rm=T),
              tot=sum(value, na.rm=T),
              n=length(na.omit(value)))
  return(data1)
}

#function to mke summaries pooled by specified grouping. indata must be in long format with value, variable, RS, Condition, unit.type and ROI fields
make.summary=function(indata, poolby, OUTdir){
  #pool results by group specified
  if(poolby=="RScond"){groupeddata=indata%>%group_by(RS, Condition, unit.type, variable, ROI)
  create.subdirs(OUTdir, "byRScond")
  subOUTdir=paste(OUTdir, "byRScond", sep="\\")
  }
  if(poolby=="RS"){groupeddata=indata%>%group_by(RS, unit.type, variable, ROI)%>%select(-Condition)%>%distinct()
  create.subdirs(OUTdir, "byRS")
  subOUTdir=paste(OUTdir, "byRS", sep="\\")
  }
  if(poolby==""){groupeddata=indata%>%group_by(unit.type, variable, ROI)%>%select(-RS,-Condition)%>%distinct()
  create.subdirs(OUTdir, "byAll")
  subOUTdir=paste(OUTdir, "byAll", sep="\\")
  }
  #summarize variable with count, mean, max, median and sd.
  outdata=summarize.f(groupeddata, value)
  write.csv(outdata, paste(subOUTdir ,"\\stats",".csv", sep=""), row.names=F)
  return(outdata)
}

#function that includes make.summary and summarize.f. writes summary and plots
#To do----------------------------------------------
#clean up xlab so it doesn't appear
#get rid fo repetivenesss in code.  figure out ggplot better.
#omit na prior to plotting so we don't get so many warning messages
make.outputs=function(indata, poolby, plottype, OUTdir, myfacet="variable", myscales="free", RSlevels){
  
  if(is.na(RSlevels)[1]==F){
  indata$RS=factor(indata$RS,levels=RSlevels)}
  
  if(poolby==""){
    indata1=indata%>%select(-RS,-Condition)%>%distinct()
    facetcol=which(colnames(indata1)==myfacet)
    p1= ggplot(indata1) +
      aes(x = factor(variable), y = value) + 
      facet_grid(~indata1[,facetcol])+
      facet_wrap( ~ indata1[,facetcol], scales=myscales)+
      geom_boxplot()
    create.subdirs(OUTdir, "byAll")
    subOUTdir=paste(OUTdir, "byAll", sep="\\")
  }
  if(poolby=="RS"){
    indata1=indata%>%select(-Condition)%>%distinct()
    facetcol=which(colnames(indata1)==myfacet)
    p1=ggplot(indata1) +
      aes(x = factor(RS), y = value) + 
      facet_grid(~indata1[,facetcol])+
      facet_wrap( ~ indata1[,facetcol], scales=myscales)+
      geom_boxplot() 
    create.subdirs(OUTdir, "byRS")
    subOUTdir=paste(OUTdir, "byRS", sep="\\")
  }
  if(poolby=="RScond"){
    facetcol=which(colnames(indata)==myfacet)
    p1=ggplot(indata) +
      aes(x = factor(RS), y = value, fill=Condition) + 
      scale_fill_manual(values = condition.fill)+
      facet_grid(~indata[,facetcol])+
      facet_wrap( ~ indata[,facetcol], scales=myscales)+
      geom_boxplot()
    create.subdirs(OUTdir, "byRScond")
    subOUTdir=paste(OUTdir, "byRScond", sep="\\")
  }
  
  outdata=make.summary(indata, poolby, OUTdir)
  outname=paste(subOUTdir ,"\\boxplots", sep="")
  
  if(plottype==".pdf"){
    ggsave(paste(outname, ".pdf", sep=""), plot=p1, width = 10, height = 7 )
    }
  
  if(plottype==".png"){
    ggsave(paste(outname, ".png", sep=""), plot=p1, width = 10, height = 7)
    }
  
  if(plottype==".tiff"){
    ggsave(paste(outname,".tiff", sep=""), plot=p1, width = 10, height =7)
    }
  
  return(outdata)
}


#very similar to make.outputs, just boxplots filled by Unit types rather than condition dependent upon set.levels.colors()
#to do----------------------------------------------------------
#make xlabels vertical rather than horizontal so I can read them
#2 levels of facet wrapping for conditin and RS- separate x axis somehow so it is easier to read and understand.
make.outputs.unit=function(indata, poolby, gu.type, plottype, OUTdir, myfacet="variable", myscales="free", RSlevels, myunitcolname="unit.type"){
  
  a=set.levels.colors(indata, gu.type=gu.type, unitcolname=myunitcolname)
  indata=a$mydata
  unitcolors=a$unitcolors
  
  if(is.na(RSlevels)[1]==F){
    indata$RS=factor(indata$RS,levels=RSlevels)}
  
  
  if(poolby==""){
    indata1=indata%>%select(-RS,-Condition)%>%distinct()
    facetcol=which(colnames(indata1)==myfacet)
    p1= ggplot(indata1) +
      aes(x = factor(Unit), y = value, fill=Unit) + 
      scale_fill_manual(values = unitcolors)+
      facet_grid(~indata1[,facetcol])+
      facet_wrap( ~ indata1[,facetcol], scales=myscales)+
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))+
      geom_boxplot()
    create.subdirs(OUTdir, "byAll")
    subOUTdir=paste(OUTdir, "byAll", sep="\\")
  }
  
  if(poolby=="RS"){
    indata1=indata%>%select(-Condition)%>%distinct()
    facetcol=which(colnames(indata1)==myfacet)
    p1=ggplot(indata1) +
      aes(x = factor(Unit), y = value, fill=Unit) + 
      scale_fill_manual(values = unitcolors)+
      facet_grid(indata1[,facetcol]~RS, scales=myscales)+
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))+
      geom_boxplot() 
    create.subdirs(OUTdir, "byRS")
    subOUTdir=paste(OUTdir, "byRS", sep="\\")
  }
  
#does it even make sense to plot condition for different units since the condition is really about the reach...  

 if(poolby=="RScond"){
    facetcol=which(colnames(indata)==myfacet)
    #RScond=paste(indata$RS,indata$Condition)
    p1=ggplot(indata) +
      aes(x = factor(Unit), y = value, fill=Condition) + 
      scale_fill_manual(values = condition.fill)+
      facet_grid(indata[,facetcol]~RS, scales=myscales)+
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))+
      geom_boxplot()
    create.subdirs(OUTdir, "byRScond")
    subOUTdir=paste(OUTdir, "byRScond", sep="\\")
  }
  
  outdata=make.summary(indata, poolby, OUTdir)
  outname=paste(subOUTdir ,"\\boxplots", sep="")
  
  if(plottype==".pdf"){
    ggsave(paste(outname, ".pdf", sep=""), plot=p1, width =15, height = 15 )
  }
  
  if(plottype==".png"){
    ggsave(paste(outname, ".png", sep=""), plot=p1, width = 15, height = 15)
  }
  
  if(plottype==".tiff"){
    ggsave(paste(outname,".tiff", sep=""), plot=p1, width = 15, height =15)
  }
  
  return(outdata)
}

#Set plotting colors and levels depending on gu.type #depends on already sourcing the script plot.colors
set.levels.colors=function(mydata, gu.type, myGUPdir=GUPdir, unitcolname){

source(paste(myGUPdir, "\\scripts\\plot.colors.R", sep=""))

mydata=as.data.frame(mydata)
unitcol=which(names(mydata)==unitcolname)
  
if(gu.type=="UnitShape"){
  unitcolors= shape.fill
  mydata$Unit=factor(mydata[,unitcol], levels=shape.levels)
  
}

if(gu.type=="UnitForm"){
  unitcolors= form.fill
  
  if(layer=="Tier2_InChannel_Transition"){
    mydata$Unit=factor(mydata[,unitcol], levels=form.t.levels)
  }
  if(layer=="Tier2_InChannel"){
    mydata$Unit=factor(mydata[,unitcol], levels=form.levels)
  }
}

if(gu.type=="GU"){
  unitcolors=gu.fill
  mydata$Unit=factor(mydata[,unitcol], levels=gu.levels)
}

#print("Unit Colors=")
#print(unitcolors)

#print("GU levels=")
#print(levels(mydata$Unit))

#print(head(mydata))

return(list(mydata=mydata, unitcolors=unitcolors))
}

