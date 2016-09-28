# boxplot of bacteria abundance in different populations
---


### Introduction

This figure shows the boxplot distribution of each bacteria (separating by `gray` and `white` shadows in the background) in different populations (colored according to the figure legend)

The entire box is divided into two panels (by a vertical black line) with different `y-axis` scales, refering to the relative abundance

There are two built-in `cut-offs` for displaying. One is for the total number of bacteria to be plot (,with top relative abundacne, *25* as default), and the other is for dividing the two panels (by average **R**elative **A**bundance, and this cut-off is shown at the top of the plot)


### Input & Output

There is one **input** file. 

The [file][f1] is a matrix of bacteria abundance, delimited by `tab`. The **first column** is the bacterial id. Then the following columns are abundances in each individual. The **first line** is a header to indicate the column information, say sample id.

> Tips: 
+ The order of the sample columns is not important


The **output** are two figures (**PNG** and **PDF**), and one file with average abundance for each group/population and the statistical test ***p***-value.


### Usage

+ Before running, you may manually modify the script to fit your data. (See the annotations in the `plot.1.r`, say some built-in cut-offs and parameters)

```R
> Rscript plot.1.r Input_Matrix.txt
```

### Dependency

+ Basic **R** environment

### Figure Show

+ png

![png][p1]


------
------
[f1]: https://github.com/faculty/iVisual/blob/master/boxplot/plot.1/Input_Matrix.txt 

[p1]: https://github.com/faculty/iVisual/raw/master/boxplot/plot.1/Input_Matrix.boxplot.png
