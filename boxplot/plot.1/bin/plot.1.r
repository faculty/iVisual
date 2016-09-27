arg <- commandArgs(T)
if(length(arg) != 1){
	cat("Argument: Input_Matrix.txt\n")
	quit('no')
}
filepath <- dirname(arg[1])
filename <- basename(arg[1])
#level <- strsplit(filename,'.',fixed=T)[[1]][2]

## set the top N bacteria in terms of abundance to be plot
top <- 25
## set the Group Numbers, here is the number of the populations
GN <- 3
## set the Color to the Group
G2C <- c('Pop1'='red','Pop2'='blue','Pop3'='green')
## set panel cut-off, use this cut-off the separate the boxplot for different y-axis scale, for displaying.
RA_cutoff <- 0.05

Abundance <- read.table(arg[1],header=T)
Pop1.abundance <- as.matrix(data.frame(Abundance[,grep("^Pop1\\.",names(Abundance))]))
Pop2.abundance <- as.matrix(data.frame(Abundance[,grep("^Pop2\\.",names(Abundance))]))
Pop3.abundance <- as.matrix(data.frame(Abundance[,grep("^Pop3\\.",names(Abundance))]))

rownames(Pop1.abundance)=Abundance[,1]
rownames(Pop2.abundance)=Abundance[,1]
rownames(Pop3.abundance)=Abundance[,1]

Abundance <- cbind(Pop1.abundance,Pop2.abundance,Pop3.abundance)
sample2pop <- as.factor(c(rep('Pop1',ncol(Pop1.abundance)),rep('Pop2',ncol(Pop2.abundance)),rep('Pop3',ncol(Pop3.abundance))))

#######Calculate the abundance of each bacteria and boxplot the distribution

## Calculate the total abundance (across samples) of each bacteria
Total.abundance=as.matrix(data.frame(Abundance[,1:ncol(Abundance)],sum=rowSums(Abundance[,1:ncol(Abundance)])))
## Sort by the total abundance
Total.abundance=Total.abundance[order(Total.abundance[,ncol(Total.abundance)],decreasing=T),]
Total.abundance=Total.abundance[,(-1)*ncol(Total.abundance)]
Pop1.abundance=Total.abundance[,grep("^Pop1\\.",colnames(Abundance))]
Pop2.abundance=Total.abundance[,grep("^Pop2\\.",colnames(Abundance))]
Pop3.abundance=Total.abundance[,grep("^Pop3\\.",colnames(Abundance))]

## get top N bacteria
Total.abundance.top = Total.abundance
if(nrow(Total.abundance.top)>top){
	Total.abundance.top=Total.abundance.top[(-1)*c((top+1):nrow(Total.abundance.top)),]
}
Pop1.abundance.top=Total.abundance.top[,grep("^Pop1\\.",colnames(Abundance))]
Pop2.abundance.top=Total.abundance.top[,grep("^Pop2\\.",colnames(Abundance))]
Pop3.abundance.top=Total.abundance.top[,grep("^Pop3\\.",colnames(Abundance))]
## assign group and color levels for boxplot
bact.group=matrix(nrow=nrow(Total.abundance.top),ncol=ncol(Total.abundance.top));
for(b in 1:nrow(Total.abundance.top)){
	bact.group[b,]=c(rep(c(GN*(b-1)+1,GN*(b-1)+2,GN*(b-1)+3),c(ncol(Pop1.abundance.top),ncol(Pop2.abundance.top),ncol(Pop3.abundance.top))))
}
bact.name=rownames(Total.abundance.top)

#### perform test to compare the abundance of each bacteria between groups ####
Results=matrix(nrow=nrow(Total.abundance),ncol=GN+3)
rownames(Results)=rownames(Total.abundance);
colnames(Results)=c("Pop1.AVG","Pop2.AVG","Pop3.AVG","test.p","test.pBH","test.pbonferroni");
Results[,1]=apply(Pop1.abundance,1,mean);
Results[,2]=apply(Pop2.abundance,1,mean);
Results[,3]=apply(Pop3.abundance,1,mean);
## ANOVA analysis
#Results[,4]=apply(Total.abundance,1,function(x) summary(aov(x~sample2pop))[[1]][,5][1])
## If group number is larger than 2, use KW test, otherwise wilcox test is used
Results[,4]=apply(Total.abundance,1,function(x) kruskal.test(x,sample2pop)$p.value)
Results[,5]=p.adjust(Results[,4],'BH')
Results[,6]=p.adjust(Results[,4],'bonferroni')

bact.significant=rownames(Total.abundance.top);
for(i in 1:nrow(Total.abundance.top)){
	bact.significant[i] <- '   ';
	if(Results[i,'test.pBH']<0.05){bact.significant[i] <- ' * '}
	if(Results[i,'test.pBH']<0.01){bact.significant[i] <- ' ** '}
	if(Results[i,'test.pBH']<0.001){bact.significant[i] <- '***'}
}

write.table(Results,file=paste(filepath,'/',sub("\\.txt$",'.KWtest.txt',filename,fixed=F,ignore.case=T),sep=''),sep='\t',quote=F,col.names=T,row.names=T);

pdf(paste(filepath,'/',sub("\\.txt$",".boxplot.pdf",filename,fixed=F,ignore.case=T),sep=''),width=11,height=7);

## x-axis label offset
label_offset <- -5
## rectagle shadow color
shadow_color = 'grey90'
## get the left panel (of the plot) bacteria, by Relative Abundance
top_top_n = 0;
for(r in 1:nrow(Total.abundance.top)){
if(sum(Results[r,1:3])>=RA_cutoff){top_top_n = r}
else{break}
}
## Convert into percentage
Total.abundance.top.perc = Total.abundance.top*100
## set for shadow rectagle
rect_bl = seq(0.5,max(bact.group),GN*2)		## rectagle bottom left point
rect_tr = seq(GN+0.5,max(bact.group)+0.5,GN*2)	## rectagle top right point
par(mar=c(14.3,3.3,4,3.5))
boxplot(Total.abundance.top.perc[1:top_top_n,]~bact.group[1:top_top_n,],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",xlim=c(1,max(bact.group)),outline=F,ylab='',yaxt='n');
axis(2,cex.axis=1.5,line=0,labels=F)
axis(2,cex.axis=1.5,tick=F,line=-0.5)
text(x=seq(2,(GN*top-1),3),y=label_offset,labels=bact.name,xpd=T,srt=45,pos=2,font=3,cex=1.5,offset=0)
rect(rect_bl[1:ceiling(top_top_n/2)],label_offset,rect_tr[1:ceiling(top_top_n/2)],100,col=shadow_color,lty=0)
boxplot(Total.abundance.top.perc[1:top_top_n,]~bact.group[1:top_top_n,],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",add=T,outline=F,yaxt='n')
par(new=T)
boxplot(Total.abundance.top.perc[(top_top_n+1):nrow(Total.abundance.top.perc),]~bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",xlim=c(1,max(bact.group)),at=min(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]):max(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]),yaxt='n',outline=F,ylab='')
rect(rect_bl[(ceiling(top_top_n/2)+1):length(rect_bl)],label_offset,rect_tr[(ceiling(top_top_n/2)+1):length(rect_tr)],100,col=shadow_color,lty=0)
boxplot(Total.abundance.top.perc[(top_top_n+1):nrow(Total.abundance.top.perc),]~bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),],col=G2C[c('Pop1','Pop2','Pop3')],add=T,at=min(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]):max(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]),yaxt='n',xaxt='n',outline=F)
abline(v=max(bact.group[1:top_top_n,])+0.5,lty=1,lwd=3,col=1)
legend(x='topright',fill=G2C,bty='n',legend=names(G2C),cex=1.2)
axis(4,cex.axis=1.5,line=0,labels=F)
axis(4,cex.axis=1.5,line=-0.3,tick=F)
mtext(side=2,line=2,'relative abundance (%)',cex=1.5)
mtext(side=4,line=2,'relative abundance (%)',cex=1.5)
mtext(side=3,line=1,at=c(mean(rect_bl[1:ceiling(top_top_n/2)]),mean(rect_bl[(ceiling(top_top_n/2)+1):length(rect_bl)])),text=c(expression(sum('R.A.')>='5%'),expression(sum('R.A.')<'5%')),cex=1.2)
axis(3,labels=bact.significant,at=seq(2,(GN*top-1),GN),tick = F,line = -1.2);
dev.off()

png(paste(filepath,'/',sub("\\.txt$",".boxplot.png",filename,fixed=F,ignore.case=T),sep=''),width=500,height=300,pointsize=7);

## x-axis label offset
label_offset <- -5
## rectagle shadow color
shadow_color = 'grey90'
## get the left panel (of the plot) bacteria, by Relative Abundance
top_top_n = 0;
for(r in 1:nrow(Total.abundance.top)){
if(sum(Results[r,1:3])>=RA_cutoff){top_top_n = r}
else{break}
}
## Convert into percentage
Total.abundance.top.perc = Total.abundance.top*100
## set for shadow rectagle
rect_bl = seq(0.5,max(bact.group),GN*2)		## rectagle bottom left point
rect_tr = seq(GN+0.5,max(bact.group)+0.5,GN*2)	## rectagle top right point
par(mar=c(14.3,3.3,4,3.5))
boxplot(Total.abundance.top.perc[1:top_top_n,]~bact.group[1:top_top_n,],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",xlim=c(1,max(bact.group)),outline=F,ylab='',yaxt='n');
axis(2,cex.axis=1.5,line=0,labels=F)
axis(2,cex.axis=1.5,tick=F,line=-0.5)
text(x=seq(2,(GN*top-1),3),y=label_offset,labels=bact.name,xpd=T,srt=45,pos=2,font=3,cex=1.5,offset=0)
rect(rect_bl[1:ceiling(top_top_n/2)],label_offset,rect_tr[1:ceiling(top_top_n/2)],100,col=shadow_color,lty=0)
boxplot(Total.abundance.top.perc[1:top_top_n,]~bact.group[1:top_top_n,],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",add=T,outline=F,yaxt='n')
par(new=T)
boxplot(Total.abundance.top.perc[(top_top_n+1):nrow(Total.abundance.top.perc),]~bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),],col=G2C[c('Pop1','Pop2','Pop3')],xaxt="n",xlim=c(1,max(bact.group)),at=min(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]):max(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]),yaxt='n',outline=F,ylab='')
rect(rect_bl[(ceiling(top_top_n/2)+1):length(rect_bl)],label_offset,rect_tr[(ceiling(top_top_n/2)+1):length(rect_tr)],100,col=shadow_color,lty=0)
boxplot(Total.abundance.top.perc[(top_top_n+1):nrow(Total.abundance.top.perc),]~bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),],col=G2C[c('Pop1','Pop2','Pop3')],add=T,at=min(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]):max(bact.group[(top_top_n+1):nrow(Total.abundance.top.perc),]),yaxt='n',xaxt='n',outline=F)
abline(v=max(bact.group[1:top_top_n,])+0.5,lty=1,lwd=3,col=1)
legend(x='topright',fill=G2C,bty='n',legend=names(G2C),cex=1.2)
axis(4,cex.axis=1.5,line=0,labels=F)
axis(4,cex.axis=1.5,line=-0.3,tick=F)
mtext(side=2,line=2,'relative abundance (%)',cex=1.5)
mtext(side=4,line=2,'relative abundance (%)',cex=1.5)
mtext(side=3,line=1,at=c(mean(rect_bl[1:ceiling(top_top_n/2)]),mean(rect_bl[(ceiling(top_top_n/2)+1):length(rect_bl)])),text=c(expression(sum('R.A.')>='5%'),expression(sum('R.A.')<'5%')),cex=1.2)
axis(3,labels=bact.significant,at=seq(2,(GN*top-1),GN),tick = F,line = -1.2);
dev.off()
