**Setup**
==========
First time you are starting the process, setup your environment. You add these two lines in your .bashrc file by vim .bashrc
    ```
    export HTS_PIPELINE_HOME=~/hts_pipeline
    source $HTS_PIPELINE_HOME/env_profile.sh
    ```
For analysis in your(user's) testing area change directory cd ~/bigdata/genomics_shared/ and you will be see Runs and RunAnalysis directory. In Runs directory you can upload sequencing run data and start analysis for yourself.This is for development and code testing purpose only.
For production purpose you need to ssh to genomics account ssh genomics@localhost and press return/enter and then enter password key for your account. You then change directory by cd /bigdata/genomics/shared/ and you will see Runs and RunAnalysis directories under this directory. You will run analysis from shared directory.


**Hi-Seq**
==========
1. Move sequencer run directory from Runs to RunAnalysis
    ```
    Must do this as the genomics user.
    mv /bigdata/genomics/shared/Runs/flowcellnum /bigdata/genomics/shared/RunAnalysis/
    ```

2. Build SampleSheet
    ```
    cd /home/researchers/RunAnalysis/flowcell322
    ```
In case John's excel file is not tab-delimited, then run
    ```
    iconv -f UTF-16 -t UTF-8 originalfile > newfile
    run ~/hts_pipeline/pre_casava/bin/create_samplesheet_hiseq.R
    USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
    ```
    * **FlowcellID** - flowcell number
    * **Samplesheet** - Excel sheet given by John
    * **Rundir** - /home/researchers/RunAnalysis/flowcell322/150514_SN279_0465_BC64T6ACXX/
4. Prepare proper formatted SampleSheet
    Rename SampleSheet.csv to SampleSheet_new.csv
    ```
    mv SampleSheet.csv SampleSheet_new.csv
    ```
    In order to run the new version of bcl2fastq we need a SampleSheet with a `[Data]` section. To create this you can create a file with the name SampleSheet.csv with the following template:
    ```
    [Header]
    IEMFileVersion,4
    Investigator Name,Neerja Katiyar
    Experiment Name,350
    Date,9/23/2015
    Workflow,GenerateFASTQ
    Application,HiSeq FASTQ Only
    Assay,TruSeq Small RNA
    Description,human small rna
    Chemistry,Default
    
    [Reads]
    50
    
    [Settings]
    ReverseComplement,0
    
    [Data]
    Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description
    ```
    Then run the following to add the barcodes to the template SampleSheet mentioned above:
    ```
    grep -P '^C7M' SampleSheet_new.csv | awk -F ',' '{print $2","$3",,,,,"$5","$10","}' >> SampleSheet.csv
    ```
    The grep regexp should match the run directory name.

    ```
    qsub -I
    
5. Demultiplexing using bcl2fastq

    bcl2fastq_run.sh
    Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1}
    ```
    
    * **FlowcellID** - flowcell number, e.g. 322
    * **RunDirectoryName** - Run directory (Example: 150903_NB501124_0002_AHHNG7BGXX)
    * **BaseMask** - NA for default (barcode length = 6) If barcode length = 8, BaseMask value will be Y*,I8 (single-end), Y*,I8, Y*          for paired-end.
    *  **SampleSheet** - Absolute path for SampleSheet
    *  **Mismatch** - Barcode mismatch (Default=1, if program shows error, then use mismatch=0 instead).

    Note: inside the output folder there should be a Reports/html directory, check inside this directory for the file "index.html". 

    Then create a symlink like so:
    ```
    ln -s Reports/html qc
    ```
    
    This should allow the Illumina web server to server the index.html.

6. Rename FASTQ files
    ```
    ~/hts_pipeline/post_casava/bin/fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
    ```
    * **FlowcellID** - flowcell number, e.g. 322
    * **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
    * **SampleSheet** - SampleSheet_new.csv (Absolute Path)
    * **UnalignedPath** - 151217_SN279_0498_AC88PKACXX/
    * **RunType** - hiseq or miseq
    * **RunDir** - 151217_SN279_0498_AC88PKACXX/

    **Note**: it is a good idea to check any duplicate symlinks inside the directory. So run the following command:
    ```
    readlink * | sort | uniq -d
    ```
    It is also a good idea to check and make sure that the proper barcodes are assigned the correct symlink:
    ```
    for fastq in $(ls flowcell344_lane*.fastq.gz); do file_barcode=$(echo $fastq | cut -d_ -f4 |cut -d. -f1); barcode=$(zcat $fastq |head -n1 | cut -d: -f10); echo "$barcode $file_barcode"; if [[ "$barcode" != "$file_barcode" ]]; then echo "FAILED"; fi; done
    ```
    
7. Generate QC report
    ```
    ~/hts_pipeline/post_casava/bin/qc_report_generate_targets.R
    USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
    ```
    
    * **FlowcellID** - flowcell number, e.g. 322 
    * **NumberOfPairs** - 1 for single-end data, and 2 for paired-end
    * **FASTQPath** - /bigdata/genomics/shared/322/
    * **TargetsPath** - ./
    * **SampleSheetPath** - SampleSheet.csv
    * **Demultiplex type** - 1 for CASAVA, 2 if user will demultiplex.
Note: In case, we need to run CASAVA again for some lanes individually, we need to add the link to Summary Statistics, i.e. to create new qc_lane directory.
    ```
    ln -s Unaligned_newlane/Basecall_Stats_C64T6ACXX/ qc_lane
    ```
    
8. Update links on Illumina web server
    ```
    ~/hts_pipeline/post_casava/bin/sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
    ```
    * **FlowcellID** - flowcell number, e.g. 322             
    * **NumberOfLanes** - 8 for Hi-seq, and 1 for Mi-seq
    * **FASTQPath** - /bigdata/genomics/shared/322

**MiSeq**
==================

Log-in to pigeon.bioinfo.ucr.edu and login to genomics account via ssh genomics@localhost. Then  change directory to /bigdata/genomics/shared/. You type ls and you will see Runs and RunAnalysis directories.
```
ssh genomics@localhost
cd /bigdata/genomics/shared/
```
Transfer Step
=============
Data is automatically tranferred to /bigdata/genomics/shared/Runs directory and stored in this format "160309_M02457_0087_000000000-AL01J"

Data is transferred with this script:
    transfer_data.sh
    Usage: transfer_data.sh {FlowcellID} {/path/to/source}
    Example with flowcell#477 here:
    477 /bigdata/genomics/shared/Runs/./160614_M02457_0105_000000000-AR9JP


Demux Step
=========
    bcl2fastq_run.sh 
    Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask}{SampleSheet} {Mismatch, default=1}
    Example with Flowcell#477:
        bcl2fastq_run.sh 477 160614_M02457_0105_000000000-AR9JP NA /bigdata/genomics/shared/RunAnalysis/flowcell477/160614_M02457_0105_000000000-AR9JP/SampleSheet.csv     1
    
    


Copy the flowcell directory
```
cp -R /bigdata/genomics/shared/Runs/flowcell_num /bigdata/genomics/shared/flowcell_ID #flowcell_ID eg. 351 (This directory will be created and the data will be copied inside the directory, 351.
```
Sample Sheet Step
=================
Create samplesheet for follow up scripts after demultiplexing step
```
    You need to be in this directory /bigdata/genomics/shared/flowcell_ID/
    Example with Flowcell#477 with change directory:
        cd /bigdata/genomics/shared/477/
        
    You need to run this script to create SampleSheet:
        create_samplesheet_miseq.R
        USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
        
        Example with Flowcell#477 :
            create_samplesheet_miseq.R 477 /bigdata/genomics/shared/RunAnalysis/flowcell477/160614_M02457_0105_000000000-AR9JP/SampleSheet.csv 160614_M02457_0105_000000000-AR9JP
```
* **FlowcellID** - flowcell number, e.g. 477
* **Samplesheet** - /bigdata/genomics/shared/RunAnalysis/flowcell477/160614_M02457_0105_000000000-AR9JP/SampleSheet.csv
* **Rundir** - 160614_M02457_0105_000000000-AR9JP

In the case of dual barcodes (i5 and i7) barcodes, please use the following script to create the samplesheet.
```
    create_samplesheet_miseq_i5_i7.R
    USAGE:: create_samplesheet_miseq_i5_i7.R <FlowcellID> <Samplesheet> <Rundir>
```
Rename Step
==========
Rename fastqs
```
    fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
    
    Example with Flowcell#477
        fastqs_rename.R 477 1 160614_M02457_0105_000000000-AR9JP/SampleSheet.csv 160614_M02457_0105_000000000-AR9JP miseq 160614_M02457_0105_000000000-AR9JP
```
* **FlowcellID** - flowcell number, e.g. 477

* **NumberOfFiles** -   1 (if there are one *.fastq.gz files inside the directory; not considering the Undetermined files)
                        2 (if there are two *.fastq.gz files inside the directory; not considering the Undetermined files)
                        
* **SampleSheet** - 160614_M02457_0105_000000000-AR9JP/SampleSheet.csv

* **UnalignedPath** - 160614_M02457_0105_000000000-AR9JP

* **RunType** - miseq

* **RunDir** - 160614_M02457_0105_000000000-AR9JP


        
QC Step
=======
Generate QC report (Same as HiSeq)
```
qc_report_generate_targets.R
USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>

    Example with Flowcell#477:
        qc_report_generate_targets.R 477 1 /bigdata/genomics/shared/477/ /bigdata/genomics/shared/477/fastq_report/ /bigdata/genomics/shared/477/160614_M02457_0105_000000000-AR9JP/SampleSheet.csv 1
    
    
```
* **FlowcellID** - flowcell number, e.g. 477
* **NumberOfPairs** - 1 (for single-end data), 2 (for paired-end data)
* **FASTQPath** - /bigdata/genomics/shared/477/
* **TargetsPath** - /bigdata/genomics/shared/477/fastq_report/
* **SampleSheetPath** - /bigdata/genomics/shared/477/160614_M02457_0105_000000000-AR9JP/SampleSheet.csv
* **Demultiplex type** - 1

URL Step
========
Create urls and update the database (same as HiSeq)
```
sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
    
    Example with Flowcell#477:
        sequence_url_update.R 477 1 /bigdata/genomics/shared/477
        
    

```
* **FlowcellID** - flowcell number, e.g. 477
* **NumberOfLanes** - 1
* **FASTQPath** - /bigdata/genomics/shared/477


**NextSeq**
===========

Log onto pigeon and go to the shred directory:
    cd /bigdata/genomics/shared/
    
Create copy of the original samplesheet from Clay's SampleSheet:

    cp /bigdata/genomics/shared/Runs/160614_NB501124_0065_AHFH7LBGXY/15057934_FC#478.csv SampleSheet.csv
    
==== Transfer STEP ====
    Run the script to transfer data:
        transfer_data.sh
        
        Usage: transfer_data.sh {FlowcellID} {/path/to/source}
        
    Example from FlowcellID#478:
        478 /bigdata/genomics/shared/Runs/./160614_NB501124_0065_AHFH7LBGXY
        
    Move data to flowcell sub-directory (flowcell478) of RunAnalysis directory:
     
        mv /bigdata/genomics/shared/Runs/./160614_NB501124_0065_AHFH7LBGXY 
                /bigdata/genomics/shared/RunAnalysis/flowcell478/
    
    
    ==== DEMUX STEP ====
    This script is used to DEMUX STEP:
    
        bcl2fastq_run.sh
        
            Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1}
            
        Example from FlowcellID#478:
        
            bcl2fastq_run.sh 478 160614_NB501124_0065_AHFH7LBGXY NA /bigdata/genomics/shared/RunAnalysis/flowcell478/160614_NB501124_0065_AHFH7LBGXY/SampleSheet.csv 1
            
            
    ==== SAMPLE SHEET STEP ====
    
    This script is used to create SAMPLE SHEET:  
        create_samplesheet_nextseq.R
        
            USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
            
        Example from FlowcellID#478:
        
            create_samplesheet_nextseq.R 478 /bigdata/genomics/shared/RunAnalysis/flowcell478/160614_NB501124_0065_AHFH7LBGXY/SampleSheet.csv  
                            160614_NB501124_0065_AHFH7LBGXY
                            
                            
    ==== RENAME STEP ====
    
    This script is used to rename the fastq files:
    
        fastqs_rename.R
        
            USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
            
        Example from FlowcellID#478:
        
            fastqs_rename.R 478 1 160614_NB501124_0065_AHFH7LBGXY/SampleSheet.csv 160614_NB501124_0065_AHFH7LBGXY nextseq
                    160614_NB501124_0065_AHFH7LBGXY
    
   
   
   ==== QC STEP ====
   
   This script is used to check the quality of the data:
   
        qc_report_generate_targets.R
        
            USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
            
        Example from FlowcellID#478:
        
            qc_report_generate_targets.R 478 1 /bigdata/genomics/shared/478/ /bigdata/genomics/shared/478/fastq_report/ /bigdata/genomics/shared/478/160614_NB501124_0065_AHFH7LBGXY/SampleSheet.csv 1
            
            
    ==== URL STEP ====
    
    This script is used to post the data on webpage:
    
        sequence_url_update_nextseq.R
        
            USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
            
        Example from FlowcellID#478:
        
            sequence_url_update_nextseq.R 478 4 /bigdata/genomics/shared/478
            
            

Log onto pigeon and create the flowcell directory
```
cd /bigdata/genomics/shared/
mkdir flowcell_number (eg.350)
cd /bigdata/genomics/shared/Runs/
sudo rsync -a flowcell365/ /bigdata/genomics/shared/RunAnalysis/flowcell365
sudo chown -R root.genomics /bigdata/genomics/shared/RunAnalysis/flowcell365
sudo chmod -R go-w /bigdata/genomics/shared/RunAnalysis/flowcell365
```

```
cd /bigdata/genomics/shared/365/
```
Place sample sheet from Clay's e-mail to this directory. Run bcl2fastq for demultiplexing inside flowcellID directory as
```
qsub -l nodes=1:ppn=64,mem=50gb,walltime=10:00:00 -d . -F "365 151116_NB501124_0009_AHHNHLBGXX NA /bigdata/genomics/shared/365/SampleSheet.csv 1" ~/hts_pipeline/bin/bcl2fastq_run.sh
Usage:: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet} {Mismatch, default=1}
Example: bcl2fastq_run.sh 356 151005_NB501124_0005_AHHNY7BGXX NA /bigdata/genomics/shared/356/SampleSheet.csv 1
```
* **FlowcellID** - flowcell number, e.g. 322
* **RunDirectoryName** - Run directory (Example: 150903_NB501124_0002_AHHNG7BGXX)
* **BaseMask** - NA for default (barcode length = 6) If barcode length = 8, BaseMask value will be Y*,I8 (single-end), Y*,I8, Y* for paired-end.
*  **SampleSheet** - Absolute path for SampleSheet
*  **Mismatch** - Barcode mismatch (Default=1, if program shows error, then use mismatch=0 instead).

Create samplesheet for NextSeq (similar to MiSeq)
```
Copy Samplesheet to Run directory
cp SampleSheet.csv /bigdata/genomics/shared/356/151005_NB501124_0005_AHHNY7BGXX/
```

Rename Sample sheet of the /365 directory
```
mv SampleSheet.csv SampleSheet_nextseq.csv
```
```
create_samplesheet_nextseq.R
USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
Example : create_samplesheet_nextseq.R 356 /bigdata/genomics/shared/356/151005_NB501124_0005_AHHNY7BGXX/SampleSheet.csv 151005_NB501124_0005_AHHNY7BGXX/
```

Make sure you are in /365 directory. Rename fastqs then:

```
fastqs_rename.R
USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
Example : fastqs_rename.R 356 2 /bigdata/genomics/shared/356/151005_NB501124_0005_AHHNY7BGXX/SampleSheet.csv 151005_NB501124_0005_AHHNY7BGXX/ nextseq 151005_NB501124_0005_AHHNY7BGXX/
```
* **FlowcellID** - flowcell number, e.g. 322
* **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
* **SampleSheet** - SampleSheet.csv
* **UnalignedPath** - Path to the run directory 
* **RunType** - nextseq
* **RunDir** - Run directory (Example: 150903_NB501124_0002_AHHNG7BGXX)
* **Demultiplex-type** - 1 for CASAVA, 2 if user will demultiplex

Generate QC report (same as HiSeq and MiSeq)
```
qsub -I -q highmem -l nodes=1:ppn=8,mem=50gb,walltime=20:00:00
cd bigdata/genomics/shared/365/
qc_report_generate_targets.R
USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
Example : qc_report_generate_targets.R 356 2 /bigdata/genomics/shared/356/ ./ /bigdata/genomics/shared/356/151005_NB501124_0005_AHHNY7BGXX/SampleSheet.csv 1
```
Update sequence urls
```
sequence_url_update_nextseq.R
USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
```

* **FlowcellID** - flowcell number, e.g. 365
* **NumberOfLanes** - 4
* **FASTQPath** - /bigdata/genomics/shared/365/

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
Illumina
BCL2Fastq
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

QC report
https://wiki.uio.no/mn/ibv/bioinfwiki/index.php/SMRT_Analysis:_Read_filtering#PacBio_quality_values

SMRT portal tutorial
http://www.pacb.com/training/IntroductiontoSMRTPortal/story.html


Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
