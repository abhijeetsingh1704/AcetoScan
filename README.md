# AcetoScan

- Version: 0.1 (20190423)
- Last modified: mån maj 06, 2019  03:31
- Sign: Abhijeet Singh (abhijeetsingh.aau@gmail.com)

## Description

The pipeline directory AcetoScan contains scripts for the MiSeq illumina data
analysis for the FTHFS amplicon sequencing.

The main script is `AcetoScan`.

## Dependencies

1. Cutadapt
2. Emboss (version 6.6.0.0)
3. Vsearch (version 2.13.0)
4. NCBI BLAST+ (2.8.1+)
5. R (3.5.2) (libraries - phyloseq, ggplot2, plotly, RColorBrewer, randomcoloR, plyr, dplyr)

## Contents of pipeline

1. SCRIPTS - Directory contains scripts required for the analysis
2. INPUT_DATA - Directory will be created where input raw data will be softlinked
3. OUTPUT_data - will be created Directory where the output of analysis will be processed and kept
4. ACETOSCAN_RESULT - Directory will be created during analysis and will contain the final results
	a. OTU sequences
	b. OTU table
	c. TAX table
	d. translation of OTUs


## Usagex

	$ bash AcetoScan
		
The script is interactive and will ask for the absolute path to Illumina rawdata.

