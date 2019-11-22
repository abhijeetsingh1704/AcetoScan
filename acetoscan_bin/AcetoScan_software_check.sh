#!/bin/bash

# File: AcetoScan_software_check.sh
# Last modified: fre Nov 22, 2019 13:27
# Sign: Abhi

###     User

user=`echo ${SUDO_USER:-${USER}}`

###     Checking if cutadapt is installed
if ! command -v "cutadapt" > /dev/null ; then
    echo -ne "\n#\tError: cutadapt not found, Aborting !!!"
    exit 1
fi

###     Checking if vsearch is installed
if ! command -v "vsearch" > /dev/null ; then
    echo -ne "\n#\tError: vsearch not found, Aborting !!!"
    exit 1
fi

###     Checking if Blast is installed
if ! command -v "blastx" > /dev/null ; then
    echo -ne "\n#\tError: NCBI Blast+ (blastx) not found, Aborting !!!"
    exit 1
fi

###     Checking if Mafft is installed
if ! command -v "mafft" > /dev/null ; then
    echo -ne "\n#\tError: Mafft not found, Aborting !!!"
    exit 1
fi

###     Checking if FastTree is installed
if ! command -v "fasttree" > /dev/null ; then
    echo -ne "\n#\tError: Fasttree (2.1.9+) not found, Aborting !!!"
    exit 1
fi

###     Checking if Bioperl is installed

if ! command -v perl -MBio::SeqIO -e 'printf "%vd\n", $Bio::SeqIO::VERSION, "\n"' > /dev/null ; then
echo -ne "\n#\tError: Bioperl not found, Aborting !!!"
    exit 1
fi

###     Checking if R and Rscript are installed
if ! command -v "R" > /dev/null ; then
    echo -ne "\n#\tError: R not found, Aborting !!!"
    exit 1
fi
#
if ! command -v "Rscript" > /dev/null ; then
    echo -ne "\n#\tError: Rscript not found, Aborting !!!"
    exit 1
fi

###     Checking if acetobase is formatted and accessible

if [ ! -f /home/$user/acetoscan/acetobase/*.phr ];then
        echo -ne "\n#\tCannot access acetobase"
        echo -ne "\n#\tTrying to Download AcetoBase"
        wget --no-check-certificate -O /home/$user/acetoscan/acetobase/AcetoBase_ref.tar.gz https://acetobase.molbio.slu.se/download/ref/1
        tar xf /home/$user/acetoscan/acetobase/AcetoBase_ref.tar.gz -C /home/$user/acetoscan/acetobase/ 
        find /home/$user/ -type f -iname "AcetoBase.fasta" -exec cp {} /home/$user/acetoscan/acetobase/AcetoBase.fasta
        cd /home/$user/acetoscan/acetobase/ && makeblastdb -in AcetoBase.fasta -dbtype prot -title AcetoBase -out AcetoBase
fi

echo -e "\n#\tEverything looks good\n"

###     End of script
