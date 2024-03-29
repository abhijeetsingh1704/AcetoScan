#!/bin/bash

#   File: INSTALL
#   Last modified: fre 13 aug 2021 16:48:37 CEST
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

    echo -e "\n#\t${YELLOW}Checking dependencies for Linux based systems${RESTORE}\n"

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

### Checking if Fasttree is installed

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

    mkdir -p "/home/${user}/acetoscan/"{bin,db,doc,dat,scripts}
    chmod -R 777 "/home/${user}/acetoscan/"

### Copying Acetoscan executable to /usr/local/bin

    if [ "$(whoami)" = 'root' ]; then

        #   Copying acetoscan executable to /usr/local/bin/ for super user
            echo -e "\n#\t${YELLOW}Installing acetoscan for ${LRED} ${user} ${RESTORE}"
            find ./bin/ -type f -name "aceto*" -exec cp {} /usr/local/bin/ \; 2>/dev/null
            find /usr/local/bin/ -type f -name "aceto*" -exec chmod 777 -R {} \; 2>/dev/null
    else
        #   Copying acetoscan executable to /home/acetoscan/ for non-super user
            echo -e "\n#\t${YELLOW}Installing acetoscan for ${LRED} ${user} ${RESTORE}\n"
            find ./bin/ -type f -name "aceto*" -exec cp {} "/home/${user}/acetoscan/bin" \; 2>/dev/null
            find "/home/${user}/acetoscan/bin" -type f -name "aceto*" -exec chmod +x {} \; 2>/dev/null
    fi

### Copying acetoscan dependencies to acetoscan_bin and allow access to all

    cp ./scripts/* "/home/${user}/acetoscan/scripts/"
    find "/home/${user}/acetoscan/scripts" -type f -name "AcetoScan*" -exec chmod +x {} \;

### Downloading and formatting AcetoBase

    #   Downloading

        echo -e "#\t${YELLOW}Downloading AcetoBase${RESTORE}\n"
        wget --no-check-certificate -O "/home/${user}/acetoscan/db/AcetoBase_ref.tar.gz" \
                https://acetobase.molbio.slu.se/download/ref/1
    #   Extracting

        echo -e "\n#\t${YELLOW}Extracting AcetoBase${RESTORE}\n"
        tar xf "/home/${user}/acetoscan/db/"AcetoBase_ref.tar.gz -C "/home/${user}/acetoscan/db/"
        find "/home/${user}/acetoscan/db/" -name AcetoBase_ref.tar.gz -exec rm -rf {} \;

    #   Formatting blast database

        echo -e "\n#\t${YELLOW}Building AcetoBase database${RESTORE}"
        makeblastdb -in /home/${user}/acetoscan/db/AcetoBase.fasta -dbtype prot -title AcetoBase -out /home/${user}/acetoscan/db/AcetoBase
        find "/home/${user}/acetoscan/db/" -type f -name "AcetoBase*" -exec chmod +x {} \;

### Installation complete

    echo -e "\n#\t${YELLOW}Installation DONE for ${LRED}${user}${RESTORE}\n"

### End of script

    exit 0
