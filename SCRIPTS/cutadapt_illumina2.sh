#!/bin/bash

# File: cutadapt_illumina.sh
# Last modified: mån maj 13, 2019  10:47
# Sign: JN

# Cutadapt script for cleaning ILLUMINA forward read data (R1), 
# requires already demplutiplexed data in the form of 
# SAMPLE_R1_001.fastq.gz.
# Also depends on environmental variable CDIR, and that
# folders ${CDIR}/OUTPUT_DATA/trimmed are present or
# able to be created.
#
# Script is only for forward reads.
#
# TODO:
# - read from $1 and write to $2?
# - put cutadapt.out in output_dir?

command -v cutadapt >/dev/null 2>&1 || { echo >&2 "Error: cutadapt not found."; exit 1; }

output_dir="${CDIR}/OUTPUT_DATA/trimmed"

mkdir -p "${output_dir}"

cutadapt_out="${CDIR}/OUTPUT_DATA/cutadapt.out"

echo "cutadapt $(date) :" > "${cutadapt_out}"

for FwdIn in *_R1_001.fastq.gz; do
    if [ ! -e "$FwdIn" ]; then
        echo "Error: No *.fastq.gz files found in ${PWD}"
        break
    else
        FwdOut="${FwdIn%%_*}_trimmed_R1.fastq.gz"
        cutadapt \
            -b CCNACNCCNNNNGGNGANGGNAA \
            -b GGNTGNGGNNNNCCNCTNCCNTT \
            -b ATNTTNGCNAANGGNCCNNCNTG \
            -b TANAANCGNTTNCCNGGNNGNAC \
            --max-n 0 \
            --maximum-length 277 \
            --minimum-length 150 \
            --discard-untrimmed \
            -j 0 \
            -q 20 \
            --length-tag "size=" \
            -o "${output_dir}/${FwdOut}" \
            "${FwdIn}" >> "${cutadapt_out}"
    fi
done

