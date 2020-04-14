# AcetoScan

- Version: 1.0 (20200414)
- Last modified: Apr 14, 2020 20:30
- Sign: Abhijeet Singh (abhijeetsingh.aau@gmail.com)

## Description

AcetoScan is a software pipeline for the analysis of Illumina MiSeq sequencing data for the FTHFS (Formyl--tetrahydrofolate synthetase) gene/amplicons

AcetoScan can also process fasta sequences to filter out non-target sequences, assigning taxonomy to the FTHFS fasta sequences and generate phylogenetic tree (see AcetoScan commands)

## Dependencies

`AcetoScan` pipeline uses some software dependencies (version equals or higher)
```
	- Cutadapt 	(2.9)
	- VSEARCH 	(2.13.1)
	- NCBI-blast+ 	(2.5.0+)
	- Bioperl 	(1.7.2-3)
	- MAFFT		(7.307)
	- Fasttree	(2.1.9)
	- R 		(3.5.2), with libraries:
		¤ phyloseq 	(1.24.2)
		¤ ggplot2 	(3.1.1)
		¤ plotly 	(4.9.0)
		¤ RColorBrewer 	(1.1.2)
		¤ plyr 		(1.8.4)
		¤ dplyr 	(0.8.0.1)
		¤ vegan		(2.5.6)	
```


## Installation

For installation run the following command in terminal, this will `INSTALL` all dependencies (if unavailable) and download the reference database from acetobase website. 
```
$ chmod +x INSTALL

$ sudo ./INSTALL
```

## Installation without sudo/ROOT

For installation as local user make sure the dependency software are installed and modules are loaded (on server environment)
```
bash INSTALL
```

## acetoscan binary

`INSTALL` will create main directory `acetoscan` in `/home/<user>/` and sub-directories `acetoscan_bin` containing dependendencies scripts & `acetobase` contains reference database

## acetoscan output

`acetoscan` will result in three directories

- Directories will be created `in default/destination path`

```
1. input_data 		- containing softlinked input raw data
```
######			Raw data must in format "Samplename_XYZ_L001_R1_001.fastq.(gz or bz2)" 
https://support.illumina.com/content/dam/illumina-support/documents/documentation/software_documentation/miseqreporter/miseq-reporter-generate-fastq-workflow-guide-15042322-01.pdf, page 9, FASTQ File Names

```				
2. output_data 		- containing process data will be generated and stored. In case of process failure, data can be accessed from here for further processing

3. acetoscan_result 	- containing all the final graphics, OTU table and TAX table. After successful execution of analysis, all the important data will be copies to this final directory.
```

## AcetoScan commands

```
$ acetoscan -X 

or

$ /home/<user>/acetoscan/acetoscan -X 
```

```

1. acetoscan       - for complete processing of raw sequence data
2. acetocheck      - for processing fasta sequences and filter out non-target sequences
3. acetotax        - acetocheck + taxonomic assignments
4. acetotree       - acetotax + phylogenetic tree generation
```

## Using acetoscan program

Use `acetoscan` as follows

```
acetoscan -i /<input path>/ [-o /<output path>/] [-m 300] [-n 120] [-q 20] [-l 24] [-r 1] [-t 0.80] [-c 2] [-e 1e-3] [-B 1000] [-P 8]


        -i      Input directory containing raw illumina data
        -o      Output directory
                        :default = /home/<user>/acetoscan/output_data
        -m      Maximum length of sequence after quality filtering
                        :default max_length = 300
        -n      Minimum length of sequence after quality filtering
                        :default min_length = 120
        -q      Quality threshold for the sequences
                        :default quality threshold = 20
        -l      Primer length
                        :default primer length = 24
        -r      Read type either forward or reverse reads
                        1 = forward reads (default), 2 = reverse reads
        -t      Clustering threshold
                        :default cluster threshold = 0.80 (80 %)
        -c      Minimum cluster size
                        :default minimum cluster size = 2
        -e      E-value
                        :default evalue = 1e-3
        -B      Bootstrap value
                        :default bootstrap = 1000
        -P      Parallel processes / threads
                        :default no. of parallels = all available threads
        -h      Print help
        -X      Print AcetoScan commands
        -v      Print AcetoScan version
        -C      Print AcetoScan citation

```


## acetocheck
Use this command for the FTHFS fasta a sequences and filter out any unspecific / non-FTHFS sequence

```
$ acetocheck -h 

```

```
acetocheck -i /path/<input_file> [-o /path/<output_file>] [-e 1e-3] [-P 8]


        -i      Input file - multifasta file
        -o      Output file
                        :default = acetocheck_<date>_<time>.fasta
        -e      E-value
                        :default evalue = 1e-3
        -P      Parallel processes/threads
                        :default no. of parallels = all available threads
        -h      Print help
        -X      Print AcetoScan commands
        -v      Print AcetoScan version
        -C      Print AcetoScan citation
```

### Use
```
acetocheck -i /home/abhi/Desktop/seq.fasta -o /home/abhi/Desktop/my_sequences -e 1e-3 -P 8
```
#### output
1. my_sequences.fasta
2. acetotax_< Date >_< Time >.log


## acetotax
Use this command for the FTHFS fasta a sequences and filter out any unspecific / non-FTHFS sequence and taxonomic annotations of the fasta sequences

```
$ acetotax -h 

```

```
acetotax -i /path/<input_file>/ [-o /path/<output_file>/] [-e 1e-3] [-P 8]

        -i      Input_file
        -o      Output file
                        :default = acetotax_<date>_<time>.csv
                        :default = acetotax_<date>_<time>.fasta
        -e      E-value
                        :default evalue = 1e-3
	-P      Parallel processes/threads
                        :default no. of parallels = all available threads
        -h      Print help        
        -X      Print AcetoScan commands
        -v      Print AcetoScan version
        -C      Print AcetoScan citation
```

### Use
```
acetotax -i /home/abhi/Desktop/seq.fasta -o /home/abhi/Desktop/my_sequences -e 1e-3 -P 8
```
#### output
1. my_sequences.fasta
2. my_sequences.csv
3. acetotax_< Date >_< Time >.log
	
	
## acetotree
Use this command for the FTHFS fasta a sequences and filter out any unspecific / non-FTHFS sequence and taxonomic annotations of the fasta sequences and generation of phylogenetic tree

```
$ acetotree -h 

```

```
acetotree -i /path/<input_file> [-o /path/<output_file>] [-e 1e-3] [-B 1000] [-P 8]


        -i      Input file - multifasta file
        -o      Output file
                        :default = acetotree_<date>_<time>.fasta
                        :default = acetotree_<date>_<time>.csv
                        :default = acetotree_<date>_<time>.aln
                        :default = acetotree_<date>_<time>.tree
        -e      E-value
                        :default evalue = 1e-3
        -B      Bootstrap value
                        :default bootstrap = 1000
        -P      Parallel processes/threads
                        :default no. of parallels = all available threads
        -h      Print help
        -X      Print AcetoScan commands
        -v      Print AcetoScan version
        -C      Print AcetoScan citation
```

### Use
```
acetotree -i /home/abhi/Desktop/seq.fasta -o /home/abhi/Desktop/my_sequences -e 1e-3 -B 1000 -P 8
```
#### output
1. my_sequences.fasta
2. my_sequences.csv
3. my_sequences.aln
4. my_sequences.tree
5. acetotax_< Date >_< Time >.log
