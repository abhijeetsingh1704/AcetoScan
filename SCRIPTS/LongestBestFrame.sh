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

echo "Performing best frame analysis on
"
echo "========="
grep -c ">" ${file} 
echo "sequences"
echo "========="
echo "
This might take a while...."

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
ls -I "*.txt" -I "*.sh" -I "${file}_PROCESSED" -I "${file}" > NAMES_READS.txt

#making the file for the final sequences
touch $DIR/LBF_analysis_pseodox214/${file}_best.fasta

#finding all ORFs 
cd $DIR/LBF_analysis_pseodox214
mkdir -p $DIR/LBF_analysis_pseodox214/GETORF_OUT

for SPLIT in $(cat NAMES_READS.txt)
	do
		echo -ne '-'
		getorf -sequence $DIR/LBF_analysis_pseodox214/$SPLIT -find 2 -table 11 -auto Y -outseq $DIR/LBF_analysis_pseodox214/GETORF_OUT/ORF_${SPLIT} &
		echo -ne '>'
	done		
echo -ne '#'



# Sorting ORFs according to size
cd $DIR/LBF_analysis_pseodox214/GETORF_OUT

find . -maxdepth 1 -name 'ORF_*.fasta' | sed 's|./||' > $DIR/LBF_analysis_pseodox214/GETORF_OUT/ORFFILE.txt

mkdir $DIR/LBF_analysis_pseodox214/SIZESEQOUT

for ORFS in $(cat ORFFILE.txt)
	do
		echo -ne '-'
		sizeseq -sequence $ORFS -descending N -auto Y -warning N -outseq $DIR/LBF_analysis_pseodox214/SIZESEQOUT/SS_${ORFS} &
		echo -ne '>'
	done
echo -ne '#'

## multi to single line fata

cd $DIR/LBF_analysis_pseodox214/SIZESEQOUT/
find . -maxdepth 1 -name 'SS_ORF_*.fasta' | sed 's|./||' > sizeselected.txt

for SSFILE in $(cat sizeselected.txt)
	do	
		echo -ne '-'
		perl -pe '/^>/ ? print "\n" : chomp' $SSFILE | tail -2 | sed 's/ /_/g;s/-/_/g' >> $DIR/LBF_analysis_pseodox214/pre_${file}_best.fasta &
		echo -ne '>' 
	done 
echo -ne '#'
sed 's/>/\n>/g' $DIR/LBF_analysis_pseodox214/pre_${file}_best.fasta | sed '/^$/d' > $DIR/LBF_analysis_pseodox214/${file}_best.fasta

#processing final file and removing blank line
cd $DIR/LBF_analysis_pseodox214/
sed -e 's/>/\n>/g;s/ /_/g;s/:/_/g' ${file}_best.fasta > ${file}_best.fasta.tmp
sed -e '/^$/d' ${file}_best.fasta.tmp > ${file}_best.fasta.tmp.str
sed -e 's/[][]//g;s/[(]//g;s/[)]//g' ${file}_best.fasta.tmp.str > ${file}_best.fasta.tmp.str_2

#parting the files into sense strand and reverse strand, two files

#Performing Sense strand analysis

#prep file
grep -e ">" ${file}_best.fasta.tmp.str_2 > ${file}_best.fasta.tmp.str_2_header
grep -v "REVERSE" ${file}_best.fasta.tmp.str_2_header | sed 's/>//g' > non_reverse_header.txt #cut -d "_" -f1 |
grep -e "REVERSE" ${file}_best.fasta.tmp.str_2_header | sed 's/>//g' > reverse_header.txt #cut -d "_" -f1 | 

#parting
#sense strand
for NON in $(cat non_reverse_header.txt) 
  do
    grep -A 1 $NON ${file}_best.fasta.tmp.str_2 &
  done > ${file}_best.fasta.tmp.str_2.non_reverse 
  
  
#reverse sense strand
for REV in $(cat reverse_header.txt) 
  do
     grep -A 1 $REV ${file}_best.fasta.tmp.str_2 &
  done > ${file}_best.fasta.tmp.str_2.reverse
  
#reverse complement reverse sense strand

if [ -f ${file}_best.fasta.tmp.str_2.reverse ];then
        revseq -sequence ${file}_best.fasta.tmp.str_2.reverse -auto Y -warning N -outseq ${file}_best.fasta.tmp.str_2.reverse.comp
        perl -pe '/^>/ ? print "\n" : chomp' ${file}_best.fasta.tmp.str_2.reverse.comp | sed -e '/^$/d' > ${file}_best.fasta.tmp.str_2.reverse.comp.fasta
   else echo "revseq not working" 
fi

cat ${file}_best.fasta.tmp.str_2.non_reverse ${file}_best.fasta.tmp.str_2.reverse.comp.fasta > Best_${file}


mv Best_${file} $DIR
cd $DIR
rm -rf $DIR/LBF_analysis_pseodox214
for i in {1..2}; do	echo "";done

#end
