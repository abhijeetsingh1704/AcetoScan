#!/bin/bash

#   File: AcetoScan_cutadapt.sh
#   Last modified: Apr 13, 2020 18:22
#   Sign: Abhi

### Cutadapt script for cleaning ILLUMINA read data,
### requires already demplutiplexed data in the form of
### SAMPLE_R*_001.fastq.(gz|bz2).

### Check cutadapt program

    command -v cutadapt >/dev/null 2>&1 || { echo >&2 "Error: cutadapt not found."; exit 1; }

### Defining process variable

    cutadapt_dir="${WKDIR}/output_data/trimmed"
    cutadapt_out="${WKDIR}/output_data/cutadapt.out"

### Making cutadapt log file

    echo "cutadapt $(date) :" > "${cutadapt_out}"

### Find the file and execute the adapter trimming and quality filtering

    for infile in $(find "${WKDIR}/input_data/" -maxdepth 1 -type l -name "*_${reads}_001.fastq.${INfileext}" ); do

        if [ ! -L "${infile}" ]; then
            echo "Error: No *.fastq.'${INfileext}' files found in ${cutinput}"
            break
        else
            In=$(basename ${infile} | sed "s/_L001_${reads}_001.fastq.${INfileext}//")
            FwdOut="${In}_trimmed_"${reads}".fasta"
            cutadapt \
                --max-n 0 \
                --trim-n \
                --maximum-length $MaxL \
                --minimum-length $MinL \
                -u ${PL} \
                --cores ${jthreads} \
                -q ${QT} \
                --max-ee 1 \
                --fasta \
                --length-tag "size=" \
                --report full \
                -o "${cutadapt_dir}/${FwdOut}" \
                "${infile}" >> "${cutadapt_out}"
        fi
    done

### End of script
