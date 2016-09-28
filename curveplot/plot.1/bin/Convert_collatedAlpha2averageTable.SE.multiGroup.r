##################################################################
## This script is provided for users of QIIME. After getting rarefaction (the collated_alpha) from QIIME pipeline, you may use this script to convert the format of the output for downstream plotting with my Rscript.
## Use this script you can get any combination (, and also only one) for the groups of the samples.
## The mean and the standard error are calculated for plotting.
## This step is before 'convert_CollateAlpha2Rformat.SE.pl'
##################################################################

arg <- commandArgs(T)
if(length(arg) != 4){
	cat("Argument: collated_alpha_Dir MappingFile(GroupInfo) output_Dir combinedGroups(quoted and combined by '&&')\nExample: Rscript thisR.r collated_alpha/ mappingFile outputDir 'groupA&&groupB'\n")
	quit('no')
}
dir = arg[1]
MF = arg[2]
opDir = arg[3]
cbG = arg[4]

if(! file.exists(opDir)){
	dir.create(opDir)
}

groups <- strsplit(cbG,"&&")[[1]]

files <- dir(dir,full.names=T,pattern="\\.txt$")

for(f in files){
	filename <- basename(f)
	data<-read.table(f,sep='\t',header=T,row.names=1)
	group<-read.table(MF,sep='\t',header=T,row.names=1,comment.char='')
	data[data=='n/a']<-NA
	xaxis<-levels(as.factor(data[,1]))
	xmax<-as.numeric(xaxis[length(xaxis)])+(as.numeric(xaxis[2])-as.numeric(xaxis[1]))

	Types <- 1
	types <- list()
	for(G in groups){
		if((! G%in%(names(group))) | length(levels(as.factor(group[,G])))==0){
			cat(paste(G," is not in ",MF," or it's MONOTYPE!\n",sep=''))
			quit('no')
		}
		Types <- Types * length(levels(as.factor(group[,G])))
		types[[G]]<-as.character(levels(group[,G]))
	}
	combT <- expand.grid(types)
	g.mean <- matrix(nrow=Types,ncol=length(levels(as.factor(data[,1]))),dimnames=list(apply(combT,1,paste,sep='',collapse='&&'),as.character(levels(as.factor(data[,1])))))
	g.se <- matrix(nrow=Types,ncol=length(levels(as.factor(data[,1]))),dimnames=list(apply(combT,1,paste,sep='',collapse='&&'),as.character(levels(as.factor(data[,1])))))
	for (s in levels(as.factor(data[,1]))){
		for(r in 1:nrow(combT)){
			s.mean <- apply(subset(data,sequences.per.sample==s,rownames(group)[apply(group[groups],1,function(x) sum(x==combT[r,])==length(groups))]),2, function(x) mean(as.numeric(as.character(x)),na.rm=T))
			s.mean[which(is.na(s.mean))] <- NA
			num = sum(!is.na(s.mean))
			g.mean[paste(as.matrix(combT)[r,],sep='',collapse='&&'),as.character(s)] <- mean(s.mean,na.rm=T)
			g.se[paste(as.matrix(combT)[r,],sep='',collapse='&&'),as.character(s)] <- sqrt(sum((s.mean-mean(s.mean,na.rm=T))^2,na.rm=T)/num)/sqrt(num-1)
		}
	}
	op_file = paste(opDir,'/',sub("\\.txt$","",filename),cbG,'.txt',sep='')
	write(paste("# ",filename,"\n","# ",cbG,sep=''),file=op_file)
	write(paste('xaxis:',paste(xaxis,sep='',collapse="\t")),file=op_file,append=T)
	write(paste("xmax: ",xmax,sep=''),file=op_file,append=T)
	col <- 1
	for(r in apply(combT,1,paste,sep='',collapse='&&')){
		write(paste(">> ",sub("&&",replacement='',r),sep=''),file=op_file,append=T)
		write(paste("color ",col,sep=''),file=op_file,append=T)
		col <- col+1
		ser <- matrix(g.mean[r,],nrow=1,dimnames=list('series'))
		se.error <- matrix(g.se[r,],nrow=1,dimnames=list('error'))
		write.table(rbind(ser,se.error),file=op_file,append=T,sep='\t',quote=F,col.names=F,row.names=T)
	}
}


