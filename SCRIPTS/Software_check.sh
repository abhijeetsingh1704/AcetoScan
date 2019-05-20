#!/bin/bash

# File: Software_check.sh
# Last modified: mån maj 20, 2019  01:13
# Sign: JN

### Checking if cutadapt is installed
if ! command -v "cutadapt" > /dev/null ; then
    echo "Error: cutadapt not found, Aborting !!!"
    exit 1
fi

### Checking if vsearch is installed
if ! command -v "vsearch" > /dev/null ; then
    echo "Error: vsearch not found, Aborting !!!"
    exit 1
fi

### Checking if getorf from Emboss is installed
if ! command -v "getorf" > /dev/null ;then
    echo "Error: EMBOSS not found, Aborting !!!"
    exit 1
fi

### Checking if Blast is installed
if ! command -v "blastx" > /dev/null ; then
    echo "Error: NCBI Blast+ (blastx) not found, Aborting !!!"
    exit 1
fi

### Checking if R and Rscript are installed
if ! command -v "R" > /dev/null ; then
    echo "Error: R not found, Aborting !!!"
    exit 1
fi
if ! command -v "Rscript" > /dev/null ; then
    echo "Error: Rscript not found, Aborting !!!"
    exit 1
fi

### Check if R packages are installed (ad hoc way)
ret=$(Rscript --default-packages=phyloseq,ggplot2,plotly,RColorBrewer,randomcoloR,plyr,dplyr -e 'q()' 2>&1 | grep -v 'Loading required package')
if [ ! -z "$ret" ] ; then
    echo "Error: Missing R package(s):"
    echo "$ret"
    exit
fi

