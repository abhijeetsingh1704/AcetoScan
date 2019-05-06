#!/bin/bash

#Cutadapt script for cleaning ILLUMINA forward read data (R1), 
#requires already demplutiplexed data in the form of 
#SAMPLE_R1_001.fastq.gz. 

#Script is only for forward reads.

exec 3>&1 4>&2

trap 'exec 2>&4 1>&3' 0 1 2 3

exec 1>$CDIR/OUTPUT_DATA/cutadapt.out 2>&1


mkdir -p $CDIR/OUTPUT_DATA/trimmed

#module load cutadapt

for file in *_R1_001.fastq.gz; do

prefix=${file%_R1_001.fastq.gz};

FwdIn=${prefix}_R1_001.fastq.gz;

prefix="${file%%_*}"

FwdOut=${prefix}_trimmed_R1.fastq.gz

#echo $FwdIn $FwdOut 

cutadapt -b CCNACNCCNNNNGGNGANGGNAA -b GGNTGNGGNNNNCCNCTNCCNTT -b ATNTTNGCNAANGGNCCNNCNTG -b TANAANCGNTTNCCNGGNNGNAC --max-n 0 --maximum-length 277 --minimum-length 150 --discard-untrimmed -j 0 -q 20 --length-tag "size=" -o $CDIR/OUTPUT_DATA/trimmed/${FwdOut} ${FwdIn};

done
#module unload cutadapt
