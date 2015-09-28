Pre-CASAVA
==========
1. Move sequencer run directory from Runs to RunAnalysis # (working on the HTS system)
    ```
    cd /home/researchers/RunAnalysis/
    mkdir flowcellnum
    cd flowcellnum
    mv /home/researchers/Runs/140513_SN279_0413_AH9G1MADXX flowcellnum
    ```

2. Create symlink from run directory back to Runs (If John asks to put flowcell on SAV)
    ```
    cd /home/researchers/Runs/
    ln -s /home/researchers/RunAnalysis/flowcellnum .
    ```

3. Build SampleSheet
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

CASAVA
======
1. Run CASAVA
On the HTS system, go to /home/casava_fastqs/flowcellnum/ and run the following:
    ```
    qsub -I
    module load bcl2fastq
    cd /bigdata/genomics/shared/RunAnalysis/flowcell350
    nohup bcl2fastq --runfolder-dir=150918_SN279_0487_AC7M9UACXX/ --processing-threads=64 --demultiplexing-threads=12 --loading-threads=4 --writing-threads=4 --output-dir=/bigdata/genomics/shared/350/150918_SN279_0487_AC7M9UACXX
    ```
    Note: inside the output folder there should be a Reports/html directory, check inside this directory for the file "index.html". 

    Then create a symlink like so:
    ```
    ln -s Reports/html qc
    ```
    
    This should allow the Illumina web server to server the index.html.

2. Rename/Move previous SampleSheet.csv to SampleSheet_old.csv
    ```
    mv SampleSheet.csv SampleSheet_old.csv # [Data] format
    mv SampleSheet_new.csv SampleSheet.csv # Old CASAVA format, no [Data] section
    ```

Post-CASAVA
===========
1. Rsync data from HTS to Biocluster (currently it is pigeon). To begin, log-in to the pigeon system:
    ```
    cd /rhome/rkaundal/hts_pipeline/post_casava/bin
    rsync_illumina_data.sh 322 # 322 is the flowcell number
    ```
        
2. Rename FASTQ files
    ```
    ~/hts_pipeline/post_casava/bin/fastqs_rename.R
    USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir> <Demultiplex-type 1- CASAVA 2- user will demultiplex>
    ```
    * **FlowcellID** - flowcell number, e.g. 322
    * **NumberOfFiles** - If we have to demultiplex: 2 for paired-end, 1 for single-end. If user has to demultiplex: 3 for paired-end, 2 for single-end
    * **SampleSheet** - SampleSheet.csv
    * **UnalignedPath** - Unaligned/
    * **RunType** - hiseq or miseq
    * **RunDir** - Unaligned/
    * **Demultiplex-type** - 1 for CASAVA, 2 if user will demultiplex

    **Note**: it is a good idea to check any duplicate symlinks inside the directory. So run the following command:
    ```
    readlink * | sort | uniq -d
    ```
    
3. Generate QC report
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
    
4. Update links on Illumina web server
    ```
    ~/hts_pipeline/post_casava/bin/sequence_url_update.R
    USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
    ```
    * **FlowcellID** - flowcell number, e.g. 322             
    * **NumberOfLanes** - 8 for Hi-seq, and 1 for Mi-seq
    * **FASTQPath** - /bigdata/genomics/shared/322

**MiSeq pipeline**
==================

Log-in to pigeon.bioinfo.ucr.edu and create the flowcell directory under /bigdata/genomics/shared/
```
cd /bigdata/genomics/shared/
mkdir flowcell_num # e.g. 351
```

Copy the flowcell directory
```
cp /bigdata/genomics/cclark/flowcell_num /bigdata/genomics/shared/flowcell_ID
```

Create samplesheet for follow up scripts after demultiplexing
```
cd /bigdata/genomics/shared/flowcell_ID/
create_samplesheet_miseq.R
USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
```
* **FlowcellID** - flowcell number, e.g. 351
* **Samplesheet** - /bigdata/genomics/shared/351/150921_M02457_0067_000000000-AJ7YY/SampleSheet.csv
* **Rundir** - 150921_M02457_0067_000000000-AJ7YY/


Rename fastqs
```
fastqs_rename.R
Error: USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir> <Demultiplex-type 1- CASAVA 2- user will demultiplex>
```
* **FlowcellID** - flowcell number, e.g. 351
* **NumberOfFiles** - 2 (if there are two *.fastq.gz files inside the directory; not considering the Undetermined files)
* **SampleSheet** - 150921_M02457_0067_000000000-AJ7YY/SampleSheet.csv
* **UnalignedPath** - 150921_M02457_0067_000000000-AJ7YY/
* **RunType** - miseq
* **RunDir** - 150921_M02457_0067_000000000-AJ7YY/
* **Demultiplex-type** - 1


Generate QC report (Same as HiSeq)
```
qc_report_generate_targets.R
USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
```
* **FlowcellID** - flowcell number, e.g. 351
* **NumberOfPairs** - 1 (for single-end data), 2 (for paired-end data)
* **FASTQPath** - /bigdata/genomics/shared/351/
* **TargetsPath** - ./
* **SampleSheetPath** - 150921_M02457_0067_000000000-AJ7YY/SampleSheet.csv
* **Demultiplex type** - 1


Create urls and update the database (same as HiSeq)
```
sequence_url_update.R
Error: USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
Execution halted
```
* **FlowcellID** - flowcell number, e.g. 351
* **NumberOfLanes** - 1
* **FASTQPath** - /bigdata/genomics/shared/351/


**NextSeq**
===========

Log onto pigeon and create the flowcell directory
```
cd /bigdata/genomics/shared/
mkdir flowcell_number (eg.350)
cd /bigdata/genomics/shared/RunAnalysis/
mkdir flowcell_num (eg. flowcell_350)
```

Copy the data from hts to pigeon

```
scp -r username@hts.int.bioinfo.ucr.edu:/home/researchers/Runs/150903_NB501124_0002_AHHNG7BGXX pigeon.bioinfo.ucr.edu:/bigdata/genomics/shared/RunAnalysis/flowcellID/
```

Run bcl2fastq for demultiplexing inside flowcellID directory
```
bcl2fastq_run.sh
Usage: bcl2fastq_run.sh {FlowcellID} {RunDirectoryName}
```

Create samplesheet for NextSeq (similar to MiSeq)
```
cp /bigdata/genomics/shared/RunAnalysis/flowcell_num/150903_NB501124_0002_AHHNG7BGXX/SampleSheet.csv /bigdata/genomics/shared/flowcellID/150903_NB501124_0002_AHHNG7BGXX/
create_samplesheet_nextseq.R
USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
```

Rename fastqs
```
fastqs_rename.R
USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir> <Demultiplex-type 1- CASAVA 2- user will demultiplex>
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
qc_report_generate_targets.R
USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>
```
Update sequence urls
```
sequence_url_update_nextseq.R
USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>
```

**General notes**:
1. In case the barcode length is not 6, one can use the --use-bases-mask option such as below for barcode length of 7:
```
/opt/bcl2fastq/1.8.4/bin/configureBclToFastq.pl --input-dir /home/researchers/RunAnalysis/flowcell344/150814_SN279_0481_AC7KC5ACXX/Data/Intensities/BaseCalls --sample-sheet /home/researchers/RunAnalysis/flowcell344/150814_SN279_0481_AC7KC5ACXX/Data/Intensities/BaseCalls/SampleSheet.csv --fastq-cluster-count 600000000 --use-bases-mask Y*,I7,Y* --output-dir /home/casava_fastqs/344/Unaligned_Lane7-8
```

Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
