# AcetoScan

- Version: 0.1 (20190423)
- Last modified: tor maj 23, 2019  12:37
- Sign: Abhijeet Singh (abhijeetsingh.aau@gmail.com)

## Description

The pipeline directory AcetoScan contains scripts for the MiSeq illumina data
analysis for the FTHFS amplicon sequencing.

The main script is `acetoscan`.

## Installation

Please see the file `INSTALL` for details. Briefly:

1. Make sure the external dependencies are installed:

    - Cutadapt (v.X.X)
    - Vsearch (v.2.13.0)
    - NCBI BLAST+ (v.2.8.1+)
    - R (v.3.5.2), with libraries:
        - phyloseq
        - ggplot2
        - plotly
        - RColorBrewer
        - randomcoloR
        - plyr
        - dplyr

2. Add the path to folder `AcetoScan/SCRIPTS` to your PATH (or add the
scripts in the folder `SCRIPTS` to your PATH).

3. Make sure you have access to the [AcetoBase]() data base. Can be retrieved by:

        wget "https://www.someserver.se/path/to/ACETOBASE_DB_DIR.gz"

## Contents of pipeline

1. `SCRIPTS` - Directory contains scripts required for the analysis
2. `INPUT_DATA` - Directory will be created where input raw data will be softlinked
3. `OUTPUT_data` - Will be created. Directory where the output of analysis will be processed and kept.
4. `ACETOSCAN_RESULT` - Directory will be created during analysis and will contain the final results:
	a. OTU sequences
	b. OTU table
	c. TAX table
	d. Translation of OTUs


## Usage

	$ ./acetoscan
		
The script is interactive and will ask for the absolute path to Illumina rawdata.

