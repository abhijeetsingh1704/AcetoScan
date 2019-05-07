#!/bin/bash

# File: Software_check.sh
# Last modified: tis maj 07, 2019  10:52
# Sign: JN

###	Checking if cutadapt is installed
if ! command -v "cutadapt" > /dev/null ;then
	echo "cutadapt not found, Aborting !!!"
    exit 1
fi

###	Checking if vsearch is installed
if command -v "vsearch" > /dev/null ;then
	echo "vsearch not found, Aborting !!!"
    exit 1
fi

###	Checking if getorf from Emboss is installed
if ! command -v "getorf" > /dev/null ;then
	echo "EMBOSS not found, Aborting !!!"
    exit 1
fi

###	Checking if Blast is installed
if ! command -v "blastx" > /dev/null ; then
    echo "NCBI Blast+ (blastx) not found, Aborting !!!"
    exit 1
fi

###	Checking if R is installed
if ! command -v "R" > /dev/null ;then
	echo "R not found, Aborting !!!"
    exit 1
fi
if ! command -v "Rscript" > /dev/null ;then
	echo "Rscript not found, Aborting !!!"
    exit 1
fi

### Check if R packages are installed (ad hoc way)
if Rscript --default-packages=phyloseq,ggplot2,plotly,RColorBrewer,randomcoloRrandomcoloRplyr,dplyr -e 'q()' &> /dev/null ; then
    Rscript --default-packages=phyloseq,ggplot2,plotly,RColorBrewer,randomcoloR,plyr,dplyr -e 'q()' 2>&1 | grep 'not found'
    exit 1
fi
