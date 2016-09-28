
arg <- commandArgs(T)
if(length(arg) != 1){
	cat("Argument: Input_Matrix.txt\n")
	quit('no')
}

data<-read.table(arg[1],header=T)
dir <- dirname(arg[1])
filename <- basename(arg[1])

## set backgroud color, remember to use the transparency(AA) digits ('##RRGGBBAA')
bg.color <- '#66CDAA20'
## set color scheme
## The names of the corresponding colors should match the header line in the input file (prefix, say 'Pop1.mean')
colors<-c('Pop1'='red','Pop2'='blue','Pop3'='green')
## set the color of background dash lines (grids)
grid_col <- 'gray70'

## set the rarefaction stepwise for subsampling (if you used QIIME, you should be familiar with this). This is acutally the stepwise between the input file lines (i.e. the first column. In this case, you should set the next 'stepwise' parameter to 1)
rarefaction_step <- 100
## set the stepwise for picking lines/rows from the input file. Therefore, the actual rarefaction step should be stepwise * rarefaction_step
stepwise <- 1 
## set the unit for x-axis labeling (between adjacent ticks)
unit <- 1000
## set the step for placing y-axis ticks (between adjacent ticks)
y.step=400
## set the step for placing x-axis ticks (between adjacent ticks)
x.step=1 
## set the factor of the s.e. error bar (horizontal ticks), the larger the shorter of the ticks.
ebf=4

x.max <- max(data[,1])
y.max <- 0
for(c in seq(2,ncol(data),2)){
	y.max <- ifelse(y.max<max(data[,c]+data[,c+1]), max(data[,c]+data[,c+1]), y.max)
}
## This may need manually set, if you don't satisfy the final output
y.max <- 1800			# for finalization

pdf(paste(dir,"/",sub("\\.txt$",".rarefaction.pdf",filename),sep=''),height=6,width=8)
plot(x=1,y=1,type='n',xlim=c(0,x.max/unit),ylim=c(0,y.max),axes=F,xlab='',ylab='')
rect(0,0,x.max/unit,y.max,col=bg.color,border=NA)
segments(seq(0,x.max/unit,x.step),0,seq(0,x.max/unit,x.step),y.max,col=grid_col,lty=3,lwd=0.8)
segments(0,seq(0,y.max,y.step),x.max/unit,seq(0,y.max,y.step),col=grid_col,lty=3,lwd=0.8)
for(c in seq(2,ncol(data),2)){
	sub<-seq(1,nrow(data),stepwise)
	points(data[sub,1]/unit,data[sub,c],type='o',pch=20,col=colors[strsplit(names(data)[c],'\\.')[[1]][1]],cex=0.5)
	segments(data[sub,1]/unit,data[sub,c]-data[sub,c+1],data[sub,1]/unit,data[sub,c]+data[sub,c+1],lwd=1,col=colors[strsplit(names(data)[c],'\\.')[[1]][1]])
	segments(data[sub,1]/unit-rarefaction_step/unit/ebf,data[sub,c]-data[sub,c+1],data[sub,1]/unit+rarefaction_step/unit/ebf,data[sub,c]-data[sub,c+1],lwd=1,col=colors[strsplit(names(data)[c],'\\.')[[1]][1]])
	segments(data[sub,1]/unit-rarefaction_step/unit/ebf,data[sub,c]+data[sub,c+1],data[sub,1]/unit+rarefaction_step/unit/ebf,data[sub,c]+data[sub,c+1],lwd=1,col=colors[strsplit(names(data)[c],'\\.')[[1]][1]])
}

## plot entire box edge to be plot
## left line
segments(0,0,0,y.max,col=1)
## bottom line
segments(0,0,x.max/unit,0,col=1)
## top line
#segments(0,y.max,x.max/unit,y.max,col=1)
## right line
#segments(x.max/unit,0,x.max/unit,y.max,col=1)

axis(1,at=seq(0,x.max/unit,x.step),tck=0,pos=0,cex.axis=0.85,mgp=c(3,0.3,0))
mtext(text=expression('Reads/Sample (x10'^3*')'),1,line=1,cex=0.80)
axis(2,at=seq(0,y.max,y.step),tck=0,pos=0,las=2,tick=T,cex.axis=0.85,mgp=c(3,0.5,0))
mtext(text="# of observed OTUs",side=2,line=1.5,cex=0.85)
legend(x='bottomright',bty='n',pch=20,col=colors,legend=names(colors),lwd=1,cex=0.80,inset=c(0.05,0.05))
dev.off()

