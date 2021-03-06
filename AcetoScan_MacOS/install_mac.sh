#!/bin/bash

#   File: INSTALL
#   Last modified: mån  1 jun 2020 13:21:04 CEST
#   Sign: Abhi

### Setting colour variables

    RESTORE='\033[0m'
    YELLOW='\033[01;33m'
    LRED='\033[01;31m'

### Setting pipefail

    set -euo pipefail

### Installation

### Username

    user="${SUDO_USER:-${USER}}"

### Checking and installing Dependencies

    echo -e "\n#\t${YELLOW}Checking dependencies for MacOS${RESTORE}\n"

### Checking if cutadapt is installed

    if command -v "cutadapt" > /dev/null ; then
        echo -e "#\t${YELLOW}Cutadapt found${RESTORE}\n"
        cutadapt --version
        echo -e ""
    else
        echo -e "#\t${LRED}Please install Cutadapt${RESTORE}\n"
    fi

### Checking if vsearch is installed

    if command -v "vsearch" > /dev/null ; then
        echo -e "#\t${YELLOW}VSEARCH found${RESTORE}\n"
        vsearch --version
    else
        echo -e "#\t${LRED}Please install VSEARCH${RESTORE}\n"
    fi

### Checking if Blast is installed

    if command -v "blastx" > /dev/null ; then
        echo -e "#\t${YELLOW}ncbi-blast+ found${RESTORE}\n"
        blastx -version
        echo -e ""
    else
        echo -e "#\t${LRED}Please install ncbi-blast+${RESTORE}\n"
    fi

### Checking if MAFFT is installed

    if command -v "mafft" > /dev/null ; then
        echo -e "#\t${YELLOW}MAFFT found${RESTORE}\n"
        VER=$(which mafft)
        head ${VER} | grep version | cut -d ";" -f1
        echo -e ""
    else
        echo -e "#\t${LRED}Please install mafft${RESTORE}\n"
    fi

### Checking if FastTree is installed

    if command -v "fasttree" > /dev/null ; then
        echo -e "#\t${YELLOW}Fasttree found${RESTORE}\n"
    else
        echo -e "#\t${LRED}Please install fasttree${RESTORE}\n"
    fi

### Checking if bioperl is installed

    if command -v perl -MBio::SeqIO -e 'printf "%vd\n", $Bio::SeqIO::VERSION, "\n"' > /dev/null ; then
        echo -e "#\t${YELLOW}BioPerl found${RESTORE}\n"
        perl -MBio::SeqIO -e 'printf "%vd\n", $Bio::SeqIO::VERSION, "\n"'
        echo -e ""
    else
        echo -e "#\t${LRED}Please install BioPerl${RESTORE}\n"
    fi

### Checking if R and Rscript are installed

    if command -v "R" > /dev/null ; then
        echo -e "#\t${YELLOW}R found${RESTORE}\n"
        R --version
    else
        echo -e "#\t${LRED}Please install R and required packages${RESTORE}\n"
    fi

### Fixing the directory for AcetoScan program

    mkdir -p "/Users/${user}/acetoscan/"{bin,db,doc,scripts}
    chmod -R 777 "/Users/${user}/acetoscan/"

### Copying Acetoscan executable to /usr/local/bin

    if [ "$(whoami)" = 'root' ]; then

        #   Copying acetoscan executable to /usr/local/bin/ for super user
            echo -e "\n#\t${YELLOW}Installing acetoscan for ${user} ${RESTORE}"
            find ./bin/ -type f -name "aceto*" -exec cp {} /usr/local/bin/ \; 2>/dev/null
            find /usr/local/bin/ -type f -name "aceto*" -exec chmod 777 -R {} \; 2>/dev/null
    else
        #   Copying acetoscan executable to /Users/${user}/acetoscan/ for non-super user
            echo -e "\n#\t${YELLOW}Installing acetoscan for ${user} ${RESTORE}\n"
            find ./bin/ -type f -name "aceto*" -exec cp {} "/Users/${user}/acetoscan/bin" \; 2>/dev/null
            find "/Users/${user}/acetoscan/bin" -type f -name "aceto*" -exec chmod +x {} \; 2>/dev/null
    fi

### Copying acetoscan dependencies to acetoscan_bin and allow access to all

    cp ./scripts/* "/Users/${user}/acetoscan/scripts/"
    find "/Users/${user}/acetoscan/scripts" -type f -name "AcetoScan*" -exec chmod +x {} \;

### Downloading and formatting AcetoBase

    #   Downloading

        echo -e "#\tDownloading AcetoBase\n"
        wget --no-check-certificate -O "/Users/${user}/acetoscan/db/AcetoBase_ref.tar.gz" \
                https://acetobase.molbio.slu.se/download/ref/1
    #   Extracting

        echo -e "\n#\tExtracting AcetoBase\n"
        tar xvzf "/Users/${user}/acetoscan/db/"AcetoBase_ref.tar.gz -C "/Users/${user}/acetoscan/db/" --strip-components 1
        rm "/Users/${user}/acetoscan/db/"AcetoBase_ref.tar.gz

    #   Formatting blast database

	echo -e "\n#\tBuilding AcetoBase database"
	if ! command -v "makeblastdb" > /dev/null ; then

            echo -e "\n#\t${YELLOW}Please install ncbi-blast+${RESTORE}\n"
        else
            cd "/Users/$user/acetoscan/db/" && makeblastdb -in AcetoBase.fasta -dbtype prot -title AcetoBase -out AcetoBase
            find "/Users/$user/acetoscan/db/" -type f -name "AcetoBase*" -exec chmod +x {} \;
        fi



### Installation complete

    echo -e "\n#\t${YELLOW}Installation DONE for ${LRED}${user} ${RESTORE}\n"

### End of script

    exit 0
