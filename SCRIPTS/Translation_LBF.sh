#!/usr/bin/env bash

#setting current directory as working directory
DIR=`pwd`
#setting up the input fasta file
if [ "$#" -gt 0 ]; then
	file=$1
else
echo "Enter your multifasta file name:"
read -p 'Filename: ' file
fi
#Checking if input file is assessible
if [ -z "$file" ];then
        echo ""
        echo "No input file provided, Aborting!!!
        " && exit
fi
if [ ! -f $file ]; then
    echo "
ERROR: File \"$file\" not found in \"$DIR\"  
"
    exit 0
fi
echo "Processing: $file"

# Dependencies >> EMBOSS

echo "

Translating OTU sequence to Amino acid sequence"

echo "========="
grep -c ">" ${file} 
echo "OTU sequences"
echo "========="

#checking if emboss is installed
if command -v "getorf" >/dev/null ;then
        echo ""
  else
    	echo "Emboss not found, Aborting!!! ,
Please install emboss by <apt-get install emboss> or similar 
To install all dependencies, run the following code:
sudo apt-get update
sudo apt-get install emboss
" && exit 1
fi

#preparing the analysis directory
rm -fr $DIR/LBF_analysis_pseodox214
mkdir -p $DIR/LBF_analysis_pseodox214
cp ${file} $DIR/LBF_analysis_pseodox214
cd $DIR/LBF_analysis_pseodox214

#removing all illegal characters from fasta files
sed -i 's/:/_/g;s/-/_/g;s/ /_/g' ${file}

#
cat ${file} |\
awk '/^>/ {if(N>0) printf("\n"); printf("%s\n",$0);++N;next;} { printf("%s",$0);} END {printf("\n");}' |\
split -l 2 --additional-suffix=.fasta - Read_
ls -I "*.txt" -I "*.sh" -I "${file}_PROCESSED" -I "${file}" > fasta_names.txt

#making the file for the final sequences
touch $DIR/LBF_analysis_pseodox214/${file}_best.fasta



#finding all ORFs and Sorting
for SPLIT in $(cat fasta_names.txt)
	do
		echo -ne '-'
		getorf -sequence $SPLIT -find 2 -table 11 -auto Y -warning N -snucleotide1 -sformat1 fasta -osformat2 fasta -out ${SPLIT}_ORF #getorf from emboss
		sizeseq -sequence ${SPLIT}_ORF -snucleotide1 -descending N -auto Y -warning N -outseq ${SPLIT}_ORF_SS #sizeseq from emboss
		rm -r ${SPLIT}_ORF
		perl -pe '/^>/ ? print "\n" : chomp' ${SPLIT}_ORF_SS > ${SPLIT}_ORF_SS_linear
		rm -f ${SPLIT}_ORF_SS
		tail -2 ${SPLIT}_ORF_SS_linear >> ${file}_best.fasta
		rm -f ${SPLIT}_ORF_SS_linear fasta_names.txt $SPLIT
		echo -ne '>'
	done 
echo -ne '#'
#processing final file and removing blank line
sed -e 's/>/\n>/g;s/ /_/g;s/:/_/g' ${file}_best.fasta > ${file}_best.fasta.tmp
sed -e '/^$/d' ${file}_best.fasta.tmp > ${file}_best.fasta.tmp.str
sed -e 's/[][]//g;s/[(]//g;s/[)]//g' ${file}_best.fasta.tmp.str > ${file}_best.fasta.tmp.str_2

#parting the files into sense strand and reverse strand, two files

#prep file
grep -e ">" ${file}_best.fasta.tmp.str_2 > ${file}_best.fasta.tmp.str_2_header
grep -v "REVERSE" ${file}_best.fasta.tmp.str_2_header | sed 's/>//g' > non_reverse_header.txt #cut -d "_" -f1 |
grep -e "REVERSE" ${file}_best.fasta.tmp.str_2_header | sed 's/>//g' > reverse_header.txt #cut -d "_" -f1 | 

#parting
#sense strand
for NON in $(cat non_reverse_header.txt) 
  do
    grep -A 1 $NON ${file}_best.fasta.tmp.str_2
  done > ${file}_best.fasta.tmp.str_2.non_reverse 
  
  
#reverse sense strand
for REV in $(cat reverse_header.txt) 
  do
     grep -A 1 $REV ${file}_best.fasta.tmp.str_2
  done > ${file}_best.fasta.tmp.str_2.reverse
  
#	reverse complement reverse sense strand

#	run revseq if file exists and not empty

if [ -s ${file}_best.fasta.tmp.str_2.reverse ];then
        revseq -sequence ${file}_best.fasta.tmp.str_2.reverse -auto Y -warning N -outseq ${file}_best.fasta.tmp.str_2.reverse.comp
        perl -pe '/^>/ ? print "\n" : chomp' ${file}_best.fasta.tmp.str_2.reverse.comp | sed -e '/^$/d' > ${file}_best.fasta.tmp.str_2.reverse.comp.fasta
   else echo "" 
fi

#	Translating OTU sequence to Amino acid sequence"


transeq -frame 1 -auto Y -warning N -sequence ${file}_best.fasta.tmp.str_2.non_reverse -outseq ${file}_best.fasta.tmp.str_2.non_reverse_translation

#	find if file exists and not empty and run command

if [ -s ${file}_best.fasta.tmp.str_2.reverse.comp.fasta ];then
        transeq -frame -1 -auto Y -warning N -sequence ${file}_best.fasta.tmp.str_2.reverse.comp.fasta -outseq ${file}_best.fasta.tmp.str_2.reverse.comp.fasta_translation
        perl -pe '/^>/ ? print "\n" : chomp' ${file}_best.fasta.tmp.str_2.reverse.comp.fasta_translation | sed -e '/^$/d' > ${file}_best.fasta.tmp.str_2.reverse.comp.fasta_translation.fasta
   else echo "" 
fi

#	merge if both file exists

if [ -f ${file}_best.fasta.tmp.str_2.reverse.comp.fasta_translation ]; then
	cat ${file}_best.fasta.tmp.str_2.non_reverse_translation ${file}_best.fasta.tmp.str_2.reverse.comp.fasta_translation > Translation_Best_${file}.tmp
else
	cat ${file}_best.fasta.tmp.str_2.non_reverse_translation > Translation_Best_${file}.tmp
fi



#	transeq -sequence Best_${file} -auto Y -warning N -out Translation_Best_${file}.tmp
perl -pe '/^>/ ? print "\n" : chomp' Translation_Best_${file}.tmp | sed -e '/^$/d' | sed 's/ /_/g' | cut -d "_" -f1,2 > Translation_${file}


mv Translation_${file} $DIR
cd $DIR
rm -rf $DIR/LBF_analysis_pseodox214
#ENDTIME TIME CAPTURE


 
