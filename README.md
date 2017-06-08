**Setup**
==========
First time you are starting the process, setup your environment. You add these two lines in your .bashrc file by vim .bashrc

	```
    export HTS_PIPELINE_HOME=~/hts_pipeline
    source $HTS_PIPELINE_HOME/env_profile.sh
	```
    
For analysis in your (user's) development area change directory 

	```
	cd ~/bigdata/genomics_shared/
	``` 
	
and you will see the Runs and the RunAnalysis directories. In the Runs directory you can upload sequencing run data and start analysis for yourself. This is for development and code testing purposes only.

For production purposes you need to ssh to the genomics account 

	```
	ssh genomics@localhost
	```
	
For analysis in the production environment change directory 

	```
	cd /bigdata/genomics/shared/ 
	```
	
and you will see Runs and RunAnalysis directories under this directory. You will run analysis from shared directory.


**Hi-Seq**
==========
1. Move sequencer run directory from Runs to RunAnalysis using transfer_data.sh

	```
	~/hts_pipeline/pre_casava/bin/transfer_data.sh
	USAGE:: transfer_data.sh {FlowcellID} {/path/to/source}
	```
	
	* **FlowcellID** - flowcell number, e.g. 606
	* **/path/to/source** - path to source directory, e.g. /bigdata/genomics/shared/Runs/./170427_SN279_0538_BCBA1BACXX

2. Creating a Samplesheet_rename for internal use

	```
	~/hts_pipeline/pre_casava/bin/create_samplesheet_hiseq.R
	USAGE:: create_samplesheet_hiseq.R <FlowcellID> <Samplesheet> <Rundir>
	```
	
	* **FlowcellID** - flowcell number, e.g. 606
	* **Samplesheet** - /bigdata/genomics/shared/RunAnalysis/flowcell606/170427_SN279_0538_BCBA1BACXX/SampleSheet.csv
	* **Rundir** -  170427_SN279_0538_BCBA1BACXX
	

3. Demultiplexing using bcl2fastq

	```
    bcl2fastq_run.sh
    Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1} {NoSplit}
	```
    
    * **FlowcellID** - flowcell number, e.g. 606
    * **RunDirectoryName** - e.g. 70427_SN279_0538_BCBA1BACXX
    * **BaseMask** - Specified for every lane according to length of barcodes and in the case where all barcodes are of length 0
    * **SampleSheet** - Absolute path for SampleSheet, e.g. /bigdata/genomics/shared/606/SampleSheet.csv
    * **Mismatch** - Barcode mismatch (Default=1, if program shows error, then use mismatch=0 instead).
    * **NoSplit** - "" to indicate not to join lanes

4. Rename FASTQ files

	```
    ~/hts_pipeline/post_casava/bin/fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
	```
	
    * **FlowcellID** - flowcell number, e.g. 606
    * **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
    * **SampleSheet** - /bigdata/genomics/shared/606/SampleSheet_new.csv (Absolute Path)
    * **UnalignedPath** - 70427_SN279_0538_BCBA1BACXX/
    * **RunType** - hiseq
    * **RunDir** - 70427_SN279_0538_BCBA1BACXX/

    **Note**: it is a good idea to check any duplicate symlinks inside the directory. So run the following command:
    
	```
    readlink * | sort | uniq -d
	```
	
    It is also a good idea to check and make sure that the proper barcodes are assigned the correct symlink:
    
	```
    for fastq in $(ls flowcell606_lane*.fastq.gz); do file_barcode=$(echo $fastq | cut -d_ -f4 |cut -d. -f1); barcode=$(zcat $fastq |head -n1 | cut -d: -f10); echo "$barcode $file_barcode"; if [[ "$barcode" != "$file_barcode" ]]; then echo "FAILED"; fi; done
	```
    
    **Note**: inside the output folder there should be a Reports/html directory, check inside this directory for the file "index.html". 
    Then the script also creates a symlink to allow the Illumina web server to server the index.html:
    
	```
    ln -s Reports/html qc
	```
	
5. Generate QC report

	```
    ~/hts_pipeline/post_casava/bin/qc_report_generate_targets.R
    USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
	```
    
    * **FlowcellID** - flowcell number, e.g. 606
    * **NumberOfPairs** - 1 for single-end data, and 2 for paired-end
    * **FASTQPath** - /bigdata/genomics/shared/606/
    * **TargetsPath** - /bigdata/genomics/shared/606/fastq_report/
    * **SampleSheetPath** - /bigdata/genomics/shared/606/SampleSheet_rename.csv
    * **Demultiplex type** - 1 for bcl2fastq, 2 if user will demultiplex.
    
	**Note**: In case, we need to run CASAVA again for some lanes individually, we need to add the link to Summary Statistics, i.e. to create new qc_lane directory.

	```
    ln -s Unaligned_newlane/Basecall_Stats_C64T6ACXX/ qc_lane
	```
    
6. Update links on Illumina web server

	```
    ~/hts_pipeline/post_casava/bin/sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
	```
    
    * **FlowcellID** - flowcell number, e.g. 606            
    * **NumberOfLanes** - 8 for HiSeq
    * **FASTQPath** - /bigdata/genomics/shared/606

**MiSeq**
==================
1. Move sequencer run directory from Runs to RunAnalysis using transfer_data.sh

	```
	~/hts_pipeline/pre_casava/bin/transfer_data.sh
	USAGE:: transfer_data.sh {FlowcellID} {/path/to/source}
	```
	
	* **FlowcellID** - flowcell number, e.g. 634
	* **/path/to/source** - path to source directory, e.g. /bigdata/genomics/shared/Runs/./170530_M02457_0157_000000000-B8CV5

2. Demultiplexing using bcl2fastq

	```
    bcl2fastq_run.sh
    Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1} {NoSplit}
	```
    
    * **FlowcellID** - flowcell number, e.g. 634
    * **RunDirectoryName** - e.g. 170530_M02457_0157_000000000-B8CV5
    * **BaseMask** - Defaults to NA when barcode length is 6, "Y*,I{barcode_length},Y*" if greater than 6, "Y*,Y*" if user demultiplexes and it is single end, "Y*,Y*,Y*" if user demultiplixes and it is paired end
    * **SampleSheet** - Absolute path for SampleSheet, e.g. /bigdata/genomics/shared/634/SampleSheet.csv
    * **Mismatch** - Barcode mismatch (Default=1, if program shows error, then use mismatch=0 instead).
    * **NoSplit** - "" to indicate not to join lanes

3. Creating a Samplesheet_rename for internal use

	```
	~/hts_pipeline/pre_casava/bin/create_samplesheet_hiseq.R
	USAGE:: create_samplesheet_miseq.R <FlowcellID> <Samplesheet> <Rundir>
	```
	
	* **FlowcellID** - flowcell number, e.g. 634
	* **Samplesheet** - /bigdata/genomics/shared/RunAnalysis/flowcell634/170530_M02457_0157_000000000-B8CV5/SampleSheet.csv 
	* **Rundir** -  170530_M02457_0157_000000000-B8CV5

4. Rename FASTQ files

	```
    ~/hts_pipeline/post_casava/bin/fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
	```
	
    * **FlowcellID** - flowcell number, e.g. 634
    * **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
    * **SampleSheet** - 170530_M02457_0157_000000000-B8CV5/SampleSheet.csv
    * **UnalignedPath** - 170530_M02457_0157_000000000-B8CV5
    * **RunType** - miseq
    * **RunDir** - 170530_M02457_0157_000000000-B8CV5

    **Note**: it is a good idea to check any duplicate symlinks inside the directory. So run the following command:
    
	```
    readlink * | sort | uniq -d
	```
	
    It is also a good idea to check and make sure that the proper barcodes are assigned the correct symlink:
    
	```
    for fastq in $(ls flowcell634_lane*.fastq.gz); do file_barcode=$(echo $fastq | cut -d_ -f4 |cut -d. -f1); barcode=$(zcat $fastq |head -n1 | cut -d: -f10); echo "$barcode $file_barcode"; if [[ "$barcode" != "$file_barcode" ]]; then echo "FAILED"; fi; done
	```
    
    **Note**: inside the output folder there should be a Reports/html directory, check inside this directory for the file "index.html". 
    Then the script also creates a symlink to allow the Illumina web server to server the index.html:
    
	```
    ln -s Reports/html qc
	```
	
5. Generate QC report

	```
    ~/hts_pipeline/post_casava/bin/qc_report_generate_targets.R
    USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
	```
    
    * **FlowcellID** - flowcell number, e.g. 634
    * **NumberOfPairs** - 1 for single-end data, and 2 for paired-end
    * **FASTQPath** - /bigdata/genomics/shared/634/
    * **TargetsPath** - /bigdata/genomics/shared/634/fastq_report/
    * **SampleSheetPath** - /bigdata/genomics/shared/634/170530_M02457_0157_000000000-B8CV5/SampleSheet.csv
    * **Demultiplex type** - 1 for bcl2fastq, 2 if user will demultiplex.
    
	**Note**: In case, we need to run CASAVA again for some lanes individually, we need to add the link to Summary Statistics, i.e. to create new qc_lane directory.

	```
    ln -s Unaligned_newlane/Basecall_Stats_C64T6ACXX/ qc_lane
	```
    
6. Update links on Illumina web server

	```
    ~/hts_pipeline/post_casava/bin/sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
	```
    
    * **FlowcellID** - flowcell number, e.g. 634           
    * **NumberOfLanes** - 1 for MiSeq
    * **FASTQPath** - /bigdata/genomics/shared/634

**NextSeq**
===========
1. Move sequencer run directory from Runs to RunAnalysis using transfer_data.sh

	```
	~/hts_pipeline/pre_casava/bin/transfer_data.sh
	USAGE:: transfer_data.sh {FlowcellID} {/path/to/source}
	```
	
	* **FlowcellID** - flowcell number, e.g. 636
	* **/path/to/source** - path to source directory, e.g. /bigdata/genomics/shared/Runs/./170530_NB501891_0018_AHTLLYBGX2

2. Demultiplexing using bcl2fastq

	```
    bcl2fastq_run.sh
    Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1} {NoSplit}
	```
    
    * **FlowcellID** - flowcell number, e.g. 636
    * **RunDirectoryName** - e.g. 170530_NB501891_0018_AHTLLYBGX2
    * **BaseMask** - Defaults to NA when barcode length is 6, "Y*,I{barcode_length},Y*" if greater than 6, "Y*,Y*" if user demultiplexes and it is single end, "Y*,Y*,Y*" if user demultiplixes and it is paired end
    * **SampleSheet** - Absolute path for SampleSheet, e.g. /bigdata/genomics/shared/RunAnalysis/flowcell636/170530_NB501891_0018_AHTLLYBGX2/SampleSheet.csv
    * **Mismatch** - Barcode mismatch (Default=1, if program shows error, then use mismatch=0 instead).
    * **NoSplit** - "nosplit" to indicate to join lanes into 1 lane

3. Creating a Samplesheet_rename for internal use

	```
	~/hts_pipeline/pre_casava/bin/create_samplesheet_hiseq.R
	USAGE:: create_samplesheet_miseq.R <FlowcellID> <Samplesheet> <Rundir>
	```
	
	* **FlowcellID** - flowcell number, e.g. 636
	* **Samplesheet** - /bigdata/genomics/shared/RunAnalysis/flowcell636/170530_NB501891_0018_AHTLLYBGX2/SampleSheet.csv
	* **Rundir** -  170530_NB501891_0018_AHTLLYBGX2

4. Rename FASTQ files

	```
    ~/hts_pipeline/post_casava/bin/fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
	```
	
    * **FlowcellID** - flowcell number, e.g. 636
    * **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
    * **SampleSheet** - 170530_NB501891_0018_AHTLLYBGX2/SampleSheet.csv
    * **UnalignedPath** - 170530_NB501891_0018_AHTLLYBGX2
    * **RunType** - nextseq
    * **RunDir** - 170530_NB501891_0018_AHTLLYBGX2

    **Note**: it is a good idea to check any duplicate symlinks inside the directory. So run the following command:
    
	```
    readlink * | sort | uniq -d
	```
	
    It is also a good idea to check and make sure that the proper barcodes are assigned the correct symlink:
    
	```
    for fastq in $(ls flowcell636_lane*.fastq.gz); do file_barcode=$(echo $fastq | cut -d_ -f4 |cut -d. -f1); barcode=$(zcat $fastq |head -n1 | cut -d: -f10); echo "$barcode $file_barcode"; if [[ "$barcode" != "$file_barcode" ]]; then echo "FAILED"; fi; done
	```
    
    **Note**: inside the output folder there should be a Reports/html directory, check inside this directory for the file "index.html". 
    Then the script also creates a symlink to allow the Illumina web server to server the index.html:
    
	```
    ln -s Reports/html qc
	```
	
5. Generate QC report

	```
    ~/hts_pipeline/post_casava/bin/qc_report_generate_targets.R
    USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
	```
    
    * **FlowcellID** - flowcell number, e.g. 636
    * **NumberOfPairs** - 1 for single-end data, and 2 for paired-end
    * **FASTQPath** - /bigdata/genomics/shared/636/
    * **TargetsPath** - /bigdata/genomics/shared/636/fastq_report/
    * **SampleSheetPath** - /bigdata/genomics/shared/636/170530_NB501891_0018_AHTLLYBGX2/SampleSheet.csv
    * **Demultiplex type** - 1 for bcl2fastq, 2 if user will demultiplex.
    
	**Note**: In case, we need to run CASAVA again for some lanes individually, we need to add the link to Summary Statistics, i.e. to create new qc_lane directory.

	```
    ln -s Unaligned_newlane/Basecall_Stats_C64T6ACXX/ qc_lane
	```
    
6. Update links on Illumina web server

	```
    ~/hts_pipeline/post_casava/bin/sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
	```
    
    * **FlowcellID** - flowcell number, e.g. 636  
    * **NumberOfLanes** - 1 for NextSeq
    * **FASTQPath** - /bigdata/genomics/shared/636

**General notes**:   

1. Check if the URLs are working, if you get an error message like "Permission denied", then set appropriate permissions, for example:
	```
	chmod a+rx fastq_report
	chmod a+rx 151116_NB501124_0009_AHHNHLBGXX # similarly for other directories
	```
	or
	```
	find Reports/ -type d | xargs chmod a+rx # change permission for all sub-directories
	```
	
2. In case the barcode length is not 6, one can use the --use-bases-mask option such as below for barcode length of 7:
	```
	/opt/bcl2fastq/1.8.4/bin/configureBclToFastq.pl --input-dir /home/researchers/RunAnalysis/flowcell344/150814_SN279_0481_AC7KC5ACXX/Data/Intensities/BaseCalls --sample-sheet /home/researchers/RunAnalysis/flowcell344/150814_SN279_0481_AC7KC5ACXX/Data/Intensities/BaseCalls/SampleSheet.csv --fastq-cluster-count 600000000 --use-bases-mask Y*,I7,Y* --output-dir /home/casava_fastqs/344/Unaligned_Lane7-8
	```
	
References
==========
Illumina BCL2Fastq
https://support.illumina.com/help/SequencingAnalysisWorkflow/Content/Vault/Informatics/Sequencing_Analysis/CASAVA/swSEQ_mCA_OptionsBCLConv.htm

Illumina adapters
https://support.illumina.com/content/dam/illumina-support/documents/documentation/chemistry_documentation/experiment-design/illumina-adapter-sequences_1000000002694-01.pdf

QC report
=========
https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

Pacbio

SMRT-Analysis documentation
https://github.com/PacificBiosciences/SMRT-Analysis/wiki/Documentation

Demultiplexing
https://github.com/PacificBiosciences/pbbarcode/blob/master/doc/PbbarcodeFunctionalSpecification.rst

Barcoding with SMRT Analysis
https://github.com/PacificBiosciences/Bioinformatics-Training/wiki/Barcoding
https://github.com/PacificBiosciences/Bioinformatics-Training/wiki/Barcoding-with-SMRT-Analysis-2.3
https://github.com/PacificBiosciences/pbbarcode/blob/master/doc/PbbarcodeFunctionalSpecification.rst


QC report
https://wiki.uio.no/mn/ibv/bioinfwiki/index.php/SMRT_Analysis:_Read_filtering#PacBio_quality_values

Tutorials
http://www.pacb.com/support/training/

SMRT portal tutorial
http://www.pacb.com/training/IntroductiontoSMRTPortal/story.html

Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
