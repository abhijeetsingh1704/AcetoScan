# AcetoScan

- Version: 0.1.0 (20191024)
- Last modified: Tor Oct 25, 2019 12:27
- Sign: Abhijeet Singh (abhijeetsingh.aau@gmail.com)

## Description

Acetoscan is a bash program for the analysis of Illumina MiSeq sequencing data for the FTHFS (Formyl--tetrahydrofolate synthetase) gene/amplicons


## Dependencies

`acetoscan` uses some software dependencies
```
	- Cutadapt 	(>1.18-1)
	- Vsearch 	(>2.13.1)
	- NCBI-blast+ 	(>2.5.0+)
	- Bioperl 	(>1.7.2-3)
	- Mafft		(>7.307)
	- Fasttree	(>2.1.9)
	- R 		(>3.5.2), with libraries:
		¤ phyloseq 	(1.24.2)
		¤ ggplot2 	(3.1.1)
		¤ plotly 	(4.9.0)
		¤ RColorBrewer 	(1.1.2)
		¤ plyr 		(1.8.4)
		¤ dplyr 	(0.8.0.1)
```


## Installation

For installation run the following command in terminal, this will `INSTALL` all dependencies (if unavailable) and download the reference database from acetobase website. 
```
$ chmod +x INSTALL

$ sudo ./INSTALL
```

## Installation without sudo/ROOT

For installation as local user make user the Dependencies Software are installed and modules are loaded (on server environment)
```
chmod +x INSTALL

./INSTALL
```



## acetoscan binary

`INSTALL` will create main directory `acetoscan` in `/home/user/` and sub-directories `acetoscan_bin` containing dependendencies binaries & `acetobase` contains reference database

## acetoscan output

`acetoscan` will result in three directories

- Directories will be created `in default/destination path`

```
1. input_data 		- containing softlinked input raw data
```
######			Raw data must in format "Samplename_XYZ_L001_R1_001.fastq.gz" 
https://support.illumina.com/content/dam/illumina-support/documents/documentation/software_documentation/miseqreporter/miseq-reporter-generate-fastq-workflow-guide-15042322-01.pdf, page 9, FASTQ File Names

```				
2. output_data 		- containing process data will be generated and stored. In case of process failure, data can be accessed from here for further processing

3. acetoscan_result 	- containing all the final graphics, OTU table and TAX table. After successful execution of analysis, all the important data will be copies to this final directory.
```
## Using acetoscan program

Use `acetoscan` as follows

```
$ acetoscan -i /input path/ -o /output path/ -m 277 -n 150 -q 20 -r 1 -t 0.95 -c 5
```
#### If installation is not as sudo/root

```
$ bash /home/$user/acetoscan/acetoscan -i /input path/ -o /output path/ -m 277 -n 150 -q 20 -r 1 -t 0.95 -c 5
```
	
```
	-i      Input directory containing raw illumina data
        -o      Output directory
                        :default = /home/${user}/acetoscan/output_data
        -m      Maximum length of sequence after quality filtering
                        :defalut max_length = 277
        -n      Minimum length of sequence after quality filtering
                        :defalut min_length = 150
        -q      Quality threshold for the sequences 
                        :default quality threshold = 20
        -r      Read type either forward or reverse reads 
                        1 = forward reads (default)
                        2 = reverse reads
        -t      Clustering threshold
                        :default cluster threshold = 0.95 (95 %)
        -c      Minimum cluster size
                        :default minimum cluster size = 5      
        -h      print Help
        -v      print acetoscan version"

```
