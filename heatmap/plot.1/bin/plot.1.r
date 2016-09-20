arg <- commandArgs(T)
if(length(arg) != 2){
	cat("Argument: Input_Matrix.txt SampleInfo\n")
	quit('no')
}

getSelfPath <- function(){
## This function is used to get the path of this running script
	cmdArgs <- commandArgs(F)
        needle <- "--file="
	match <- grep(needle, cmdArgs)
	if (length(match) > 0) {
		# Rscript
		return(normalizePath(sub(needle, "", cmdArgs[match])))
	}else{
		cat("I guess your not using this script in a COMMAND Line way, just make sure the 'heatmap.frq.r' is put in the same directory as this running script!\n")
		cat("Or you may manually set the 'path' variable to the location where 'heatmap.frq.r' is.\n")
		# 'source'd via R console
		#return(normalizePath(sys.frames()[[1]]$ofile))
	}
}

## path to the location of this script, and the 'heatmap.frq.r' should be right there!
path=dirname(getSelfPath())
## grp_col is the column of the group information in the groupInfo file
grp_col <- 2
## cutoff is the cut-off for average abundance for each group, for every bacteria (in the row). If any of the group pass this cut-off, the bacteria will be shown in the plot (in one row)
cutoff <- 1
## set color for phylum (the left panel of the plot), if you want to highlight some of them
phy_col <- c('Bacteroidetes'='aquamarine2','Firmicutes'='bisque3','Proteobacteria'='olivedrab1','Actinobacteria'='plum')
## other phylum are typically set as 'gray'
phy_col_other <- c('others'='gray')
## set color for group (the top bar of the plot)
pop_col <- c('Pop1'='red','Pop2'='blue','Pop3'='green')
## set the color palette for the heatmap
colors=colorRampPalette(c("navy", "white", "firebrick3"))(20)

data <- read.table(arg[1],header=T,sep='\t')
grpInfo <- read.table(arg[2],header=T)
grps <- length(grp_col)
dir <- dirname(arg[1])
filename <- basename(arg[1])
source(paste(path,'heatmap.frq.r',sep='/'))

if(! all(sort(names(data)[c(-1,-2)])==sort(as.character(grpInfo[,1])))){
	cat("Error: The individual order and names should be exactly the same in two input files!\n")
	quit('no')
}

row.names(grpInfo)=as.character(grpInfo[,1])
dataMat <- data[,as.character(grpInfo[,1])]

## data pre-processing, replacing the negative values by the 1/10 of minimal positive one
dataMat <- dataMat/100
dataMat_min <- min(dataMat[dataMat>0])
dataMat[dataMat<=0]<-dataMat_min*0.1
dataMat<-dataMat*100

## filter for the bacterial abundance, in the population
data4plot <- dataMat[apply(as.matrix(dataMat),1,function(x) any(tapply(x,grpInfo[,2],mean)>=cutoff)),]

## log transform of the data, and set the minimal value as '-2'
data4plot <- log10(data4plot)
data4plot[data4plot<(-2)]=-2

Strain <- data[,1:2]
Strain <- data[apply(as.matrix(dataMat),1,function(x) any(tapply(x,grpInfo[,2],mean)>=cutoff)),]

## set bacteria color, by phylum. left panel
Strain_col <- c()
for(s in Strain[,1]){
	if(s %in% names(phy_col)){Strain_col <- append(Strain_col,phy_col[s])}
	else{
		Strain_col <- append(Strain_col,phy_col_other['others'])
	}
}

## set individual color, by population, top bar
PopCol <- c()
for(p in as.character(grpInfo[,grp_col])){
	if(p %in% names(pop_col)){PopCol <- append(PopCol,pop_col[p])}
	else{
		cat("Unknow population in groupInfo!\n")
		quit('no')
	}
}

## plot PNG. you may try to modify the parameters for final layout
png(paste(dir,"/",sub("\\.txt$",".heatmap.png",filename,fixed=F,ignore.case=T),sep=''),height=900,width=1000);
par(oma=c(0.1,0.1,3,0.1))
heatmap.frq(as.matrix(data4plot),ColSideColors=PopCol,Rowv=NA,Colv=NA,labRow=Strain[,2],margins=c(7,1),RowSideColors=Strain_col,verbose=F,labCol='',revC=T,cexRow=1.8,col=colors,scale='none')
par(new=T)
legend(x='bottom',fill=c(phy_col[sort(names(phy_col))],phy_col_other[sort(names(phy_col_other))]),legend=c(sort(names(phy_col)),sort(names(phy_col_other))),cex=1.5,horiz=T,border=NA,bty='n',xpd=T,inset=-0.03)
## legend of scale bar
par(new=T,fig=c(0.07,0.22,0.87,0.96),mar=c(2.6,0.1,1,0.1),oma=c(0.1,0.1,0.1,0.1))
image(as.matrix(seq(min(data4plot),max(data4plot),length.out=length(colors))),axes=F,col=colors)
axis(1,at=seq(0,1,length.out=5),labels=round(c(seq(min(data4plot),max(data4plot),length.out=5)),0),tick=F,line=-0.2,cex.axis=1.6)
mtext(expression('log'[10]*'(relative abundance %)'),side=3,line=0,cex=1.6)
dev.off()

## plot PDF. you may try to modify the parameters for final layout
pdf(paste(dir,"/",sub("\\.txt$",".heatmap.pdf",filename,fixed=F,ignore.case=T),sep=''),height=11,width=12.5);
par(oma=c(0.1,0.1,3,0.1))
heatmap.frq(as.matrix(data4plot),ColSideColors=PopCol,Rowv=NA,Colv=NA,labRow=Strain[,2],margins=c(7,1),RowSideColors=Strain_col,verbose=F,labCol='',revC=T,cexRow=1.8,col=colors,scale='none')
par(new=T)
legend(x='bottom',fill=c(phy_col[sort(names(phy_col))],phy_col_other[sort(names(phy_col_other))]),legend=c(sort(names(phy_col)),sort(names(phy_col_other))),cex=1.5,horiz=T,border=NA,bty='n',xpd=T,inset=-0.03)
## legend of scale bar
par(new=T,fig=c(0.07,0.23,0.87,0.96),mar=c(2.6,0.1,1,0.1),oma=c(0.1,0.1,0.1,0.1))
image(as.matrix(seq(min(data4plot),max(data4plot),length.out=length(colors))),axes=F,col=colors)
axis(1,at=seq(0,1,length.out=5),labels=round(c(seq(min(data4plot),max(data4plot),length.out=5)),0),tick=F,line=-0.2,cex.axis=1.3)
mtext(expression('log'[10]*'(relative abundance %)'),side=3,line=0,cex=1.6)
dev.off()

