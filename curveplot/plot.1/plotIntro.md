# rarefaction curves of bacteria/OTUs for different populations
---


### Introduction

This figure is a typical rarefaction curve for bacteria/OTUs for different groups/populations (, corresponding to different colors).

The stepwise for rarefaction, as well as final output displaying can be manually set. (see script annotations)

The box edges and the background color can be manually set. (see script annotations)


### Input & Output

There is one **input** file. 

The [file][f1] is the rarefaction results of bacteria/OTUs (, say modified from **QIIME** collated_alpha results). The **first column** is for labelling the x-axis, which is actually the subsampling number of reads. Then every two columns are one group, the first of which is the **mean** value of the corresponding statistics and the second of which is the **se** (standard errors). The **first line** is a header to indicate the column information.

The **output** is a figure (**PDF**)

>Tips:
+ For **QIIME** users, I provide you two more [scripts][f2] to convert the results from QIIME to make this plot. (see the bin directory)

### Usage

+ Before running, you may manually modify the script to fit your data. (See the annotations in the `plot.1.r`, say the groups and some parameters)
+ If you are a **QIIME** user, you may also use other two scripts

1. For **QIIME** users (I assume you are familiar with the QIIME pipeline):
```R
> Rscript Convert_collatedAlpha2averageTable.SE.multiGroup.r collated_alpha/ mappingFile output_dir/ 'groupA&&groupB'
```
```perl
> perl convert_CollateAlpha2Rformat.SE.pl average_table.txt
```
2. Making plot
```R
> Rscript plot.1.r Input_Matrix.txt
```

### Dependency

+ Basic **R** environment (and **Perl**)

### Figure Show

+ pdf

![pdf][p1]


------
------
[f1]: https://github.com/faculty/iVisual/blob/master/curveplot/plot.1/Input_Matrix.txt 
[f2]: https://github.com/faculty/iVisual/blob/master/curveplot/plot.1/bin

[p1]: https://github.com/faculty/iVisual/raw/master/curveplot/plot.1/Input_Matrix.rarefaction.png
