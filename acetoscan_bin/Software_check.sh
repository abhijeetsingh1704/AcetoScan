#!/bin/bash

# File: Software_check.sh
# Last modified: mån maj 20, 2019  01:13
# Sign: Abhi

###     User

user=`echo ${SUDO_USER:-${USER}}`

###     Checking if cutadapt is installed
if ! command -v "cutadapt" > /dev/null ; then
    echo -e "\n#Error: cutadapt not found, Aborting !!!"
    exit 1
fi

###     Checking if vsearch is installed
if ! command -v "vsearch" > /dev/null ; then
    echo -e "\n#Error: vsearch not found, Aborting !!!"
    exit 1
fi

###     Checking if Blast is installed
if ! command -v "blastx" > /dev/null ; then
    echo -e "\n#Error: NCBI Blast+ (blastx) not found, Aborting !!!"
    exit 1
fi

###     Checking if Bioperl is installed

if ! perl -MBio::Root::Version -e 'print $Bio::Root::Version::VERSION,"\n"' > /dev/null ; then
echo -e "\n#Error: Bioperl not found, Aborting !!!"
    exit 1
fi

###     Checking if R and Rscript are installed
if ! command -v "R" > /dev/null ; then
    echo -e "\n#Error: R not found, Aborting !!!"
    exit 1
fi
#
if ! command -v "Rscript" > /dev/null ; then
    echo -e "\n#Error: Rscript not found, Aborting !!!"
    exit 1
fi

###     Checking if acetobase is formatted and accessible

if [ ! -f /home/$user/acetoscan/acetobase/*.phr ];then
        echo -e "\n#Cannot access acetobase"
        echo -e "\n#Trying to Download AcetoBase"
        sudo wget -P /home/$user/acetoscan/acetobase/ "https://www.acetobase.molbio.slu.se/path/to/AcetoBase_V1.tgz"
        sudo tar xf /home/$user/acetoscan/acetobase/AcetoBase_V1.tgz -C /home/$user/acetoscan/acetobase/
fi

###     End of script
