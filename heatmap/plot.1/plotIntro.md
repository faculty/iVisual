# heatmap of bacteria abundance in different populations
---

### Introduction

This figure shows the overall distribution of each bacteria's (in the **row**) abundance in each individual (in the **column**), corresponding to different populations (**top bar**). The **left panel** shows the phylum name of each bacteria

Input data are pre-processed by following steps:

1. replace the non-positive values by (1/10 of) the minimal positive value

2. log10-transformed

3. set the minimal value as '-2'

Note there is a `cut-off` (in the script) for the average abundance of the bacteria to be plot.

### Input & Output

There are two **input** files. 

[First][f1] is a matrix of bacteria abundance, delimited by `tab`. The **second** column is the bacterial id and the **first** column is the corresponding phylum name. Then the following columns are abundances in each individual. The **first line** is a header to indicate the column information, say sample id.

[Second][f2] is a sample information/grouping file, with a header to indicate the column information. The **first column** is the sample id exactly matching the ones in the **First** file. The following columns give the corresponding grouping informations, for each sample. There is no limitation for the column number. Just give the column number you are interested in to the script (,with manually modifying) to make the plot.

> Tips: 

	+ The row order of the plot is the same as the order of the **First** input.

	+ The column order of the plot is the same as the order of the **Second** input


The **output** are two figures (**PNG** and **PDF**).


### Usage

+ First please make sure you put the two scripts in the same directory. `plot.1.r` will automatically call `heatmap.frq.r`.
+ Before running, you may manually modify the script to fit your data. (See the annotations in the `plot.1.r`)

```R
> Rscript plot.1.r Input_Matrix.txt SampleInfo
```

### Dependency

+ The scripts are tested on **R** version **2.15.2**
+ The `heatmap` package I used is extracted from **R** version **2.15**. 

### Figure Show

+ png
![png][p1]


------
------
[f1]: https://github.com/faculty/iVisual/blob/master/heatmap/plot.1/Input_Matrix.txt 
[f2]: https://github.com/faculty/iVisual/blob/master/heatmap/plot.1/SampleInfo

[p1]: https://github.com/faculty/iVisual/blob/master/heatmap/plot.1/Input_Matrix.heatmap.png
