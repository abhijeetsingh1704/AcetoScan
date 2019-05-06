#!/bin/bash

###	Checking if cutadapt is installed

if command -v "cutadapt" >/dev/null ;then
        echo "" >/dev/null
  else
	echo ""	
	echo "cutadapt not found, Aborting !!!" ; exit 1
	echo ""
fi


###	Checking if vsearch is installed

if command -v "vsearch" >/dev/null ;then
        echo "" >/dev/null
  else
	echo ""	
	echo "vsearch not found, Aborting !!!" ; exit 1
	echo ""
fi

###	Checking if Emboss is installed

if command -v "getorf" >/dev/null ;then
        echo "" >/dev/null
  else
	echo ""	
	echo "EMBOSS not found, Aborting !!!" ; exit 1
	echo ""
fi


###	Checking if Blast is installed

if command -v "blastx" >/dev/null ;then
	echo "" >/dev/null
else
	echo ""	
	echo "Blast not found, Aborting !!!" && exit 1
	echo ""
fi

###	Checking if Blast is installed

if command -v "R" >/dev/null ;then
	echo "Highly recommended to install required R libraries before proceeding !!!" 
	sleep 2
else
	echo ""	
	echo "R not found, Aborting !!!" && exit 1
	echo ""
fi
