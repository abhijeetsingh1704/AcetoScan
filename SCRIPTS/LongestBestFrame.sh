#!/usr/bin/env bash

# File: LongestBestFrame.sh
# Last modified: mån maj 13, 2019  01:51
# Sign: JN

# setting current directory as working directory
DIR=$(pwd)

# setting up the input fasta file
if [ "$#" -gt 0 ]; then
	infile="$1"
else
    echo "Enter your multifasta file name:"
    read -p 'Filename: ' infile

fi

# Checking if input file is accessible
if [ -z "${infile}" ]; then
        echo ""
        echo "No input file provided, Aborting!!!
        " && exit
fi
if [ ! -f "$infile" ]; then
    echo "
ERROR: File \"${infile}\" not found in \"${DIR}\"
"
    exit 0
fi
echo "Processing: ${infile}"

# Dependencies >> EMBOSS

# checking if emboss is installed
if ! command -v "getorf" >/dev/null ; then
    echo "Emboss not found, Aborting!!! ,
Please install emboss by <apt-get install emboss> or similar
To install all dependencies, run the following code:
sudo apt-get update
sudo apt-get install emboss
" && exit 1
fi

echo "Performing best frame analysis on
"
echo "========="
grep -c '>' "${infile}"
echo "sequences"
echo "========="
echo "
This might take a while...."

# preparing the analysis directory
rm -rf "${DIR}/LBF_analysis_pseodox214"
mkdir -p "${DIR}/LBF_analysis_pseodox214"
# TODO: ln -s instead of copying?
cp "${infile}" "${DIR}/LBF_analysis_pseodox214"

if ! cd "${DIR}/LBF_analysis_pseodox214" ; then
    echo "Error: could not cd to ${DIR}/LBF_analysis_pseodox214"
    exit 1
fi

# removing all illegal characters from fasta files
sed -i 's/:/_/g;s/-/_/g;s/ /_/g' "${infile}"

# Split infile into one fasta file per read
# TODO: avoid the splitting on multiple files
awk '/^>/ {if(N>0) printf("\n"); printf("%s\n",$0);++N;next;} { printf("%s",$0);} END {printf("\n");}' "${infile}" | \
    split -l 2 --additional-suffix=.fasta - Read_

# TODO:  try to avoid using ls and temporary file NAMES_READS.txt
ls -I "*.txt" -I "*.sh" -I "${infile}_PROCESSED" -I "${infile}" > NAMES_READS.txt

# making the file for the final sequences
touch "${DIR}/LBF_analysis_pseodox214/${infile}_best.fasta"

# finding all ORFs
if ! cd "${DIR}/LBF_analysis_pseodox214" ; then
    echo "Error: could not cd to ${DIR}/LBF_analysis_pseodox214"
    exit 1
fi

mkdir -p "${DIR}/LBF_analysis_pseodox214/GETORF_OUT"

for SPLIT in $(cat NAMES_READS.txt) ; do
    echo -ne '-'
    getorf -sequence "${DIR}/LBF_analysis_pseodox214/${SPLIT}" \
        -find 2 \
        -table 11 \
        -auto Y \
        -outseq "${DIR}/LBF_analysis_pseodox214/GETORF_OUT/ORF_${SPLIT}" &
    echo -ne '>'
done
echo -ne '#'

# Sorting ORFs according to size
if ! cd "${DIR}/LBF_analysis_pseodox214/GETORF_OUT" ; then
    echo "Error: could not cd to ${DIR}/LBF_analysis_pseodox214/GETORF_OUT"
    exit 1
fi

find . -maxdepth 1 -name 'ORF_*.fasta' | \
    sed 's|./||' > "${DIR}/LBF_analysis_pseodox214/GETORF_OUT/ORFFILE.txt"

mkdir "${DIR}/LBF_analysis_pseodox214/SIZESEQOUT"

for ORFS in $(cat ORFFILE.txt) ; do
    echo -ne '-'
    sizeseq -sequence "${ORFS}" \
        -descending N \
        -auto Y \
        -warning N \
        -outseq "${DIR}/LBF_analysis_pseodox214/SIZESEQOUT/SS_${ORFS}" &
    echo -ne '>'
done

echo -ne '#'

## multi to single line fasta
if ! cd "${DIR}/LBF_analysis_pseodox214/SIZESEQOUT" ; then
    echo "Error: could not cd to ${DIR}/LBF_analysis_pseodox214/SIZESEQOUT"
    exit 1
fi

find . -maxdepth 1 -name 'SS_ORF_*.fasta' | \
    sed 's|./||' > sizeselected.txt

for SSFILE in $(cat sizeselected.txt) ; do
    echo -ne '-'
    perl -pe '/^>/ ? print "\n" : chomp' "${SSFILE}" | \
        tail -2 | \
        sed -e 's/ /_/g' \
            -e 's/-/_/g' >> "${DIR}/LBF_analysis_pseodox214/pre_${infile}_best.fasta" &
    echo -ne '>'
done

echo -ne '#'

sed 's/>/\n>/g' "${DIR}/LBF_analysis_pseodox214/pre_${infile}_best.fasta" | \
    sed '/^$/d' > "${DIR}/LBF_analysis_pseodox214/${infile}_best.fasta"

# processing final file and removing blank line
if ! cd "${DIR}/LBF_analysis_pseodox214" ; then
    echo "Error: could not cd to ${DIR}/LBF_analysis_pseodox214"
    exit 1
fi

sed -e 's/>/\n>/g' \
    -e 's/ /_/g' \
    -e 's/:/_/g' "${infile}_best.fasta" > "${infile}_best.fasta.tmp"

sed -e '/^$/d' "${infile}_best.fasta.tmp" > "${infile}_best.fasta.tmp.str"

sed -e 's/[][]//g' \
    -e 's/[(]//g' \
    -e 's/[)]//g' "${infile}_best.fasta.tmp.str" > "${infile}_best.fasta.tmp.str_2"

# parting the files into sense strand and reverse strand, two files

# Performing Sense strand analysis

# prep file
grep -e '>' "${infile}_best.fasta.tmp.str_2" > "${infile}_best.fasta.tmp.str_2_header"
grep -v "REVERSE" "${infile}_best.fasta.tmp.str_2_header" | \
    sed -e 's/>//g' > non_reverse_header.txt #cut -d "_" -f1 |
grep -e "REVERSE" "${infile}_best.fasta.tmp.str_2_header" | \
    sed -e 's/>//g' > reverse_header.txt #cut -d "_" -f1 |

# parting
# sense strand
for NON in $(cat non_reverse_header.txt) ; do
    grep -A 1 "${NON}" "${infile}_best.fasta.tmp.str_2" &
done > "${infile}_best.fasta.tmp.str_2.non_reverse"

# reverse sense strand
for REV in $(cat reverse_header.txt) ; do
    grep -A 1 "${REV}" "${infile}_best.fasta.tmp.str_2" &
done > "${infile}_best.fasta.tmp.str_2.reverse"

# reverse complement reverse sense strand
if [ -f "${infile}_best.fasta.tmp.str_2.reverse" ]; then
    revseq -sequence "${infile}_best.fasta.tmp.str_2.reverse" \
        -auto Y \
        -warning N \
        -outseq "${infile}_best.fasta.tmp.str_2.reverse.comp"
    perl -pe '/^>/ ? print "\n" : chomp' "${infile}_best.fasta.tmp.str_2.reverse.comp" | \
        sed -e '/^$/d' > "${infile}_best.fasta.tmp.str_2.reverse.comp.fasta"
    else
        echo "Error: revseq not working"
fi

cat "${infile}_best.fasta.tmp.str_2.non_reverse" "${infile}_best.fasta.tmp.str_2.reverse.comp.fasta" > "Best_${infile}"

mv "Best_${infile}" "${DIR}"

if ! cd "${DIR}" ; then
    echo "Error: could not cd to ${DIR}"
    exit 1
fi

rm -rf "${DIR}/LBF_analysis_pseodox214"

echo -e "\n\n"
# end

