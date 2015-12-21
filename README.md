**Hi-Seq**
==========
1. Move sequencer run directory from Runs to RunAnalysis # (working on the HTS system)
    ```
    If copying data from external hard drive.
    cd /bigdata/genomics/shared/
    mkdir flowcellnum
    We can now move the raw data to the RunAnalysis folder.
    cd /bigdata/genomics/shared/RunAnalysis
    mkdir flowcell_num
    Next, we need to copy the data from hard drive to the server.
    rsync -a 151103_SN279_0493_AC84L3ACXX nkatiyar@pigeon.bioinfo.ucr.edu:/bigdata/genomics/shared/RunAnalysis/flowcell_num
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
    * **SampleSheet** - SampleSheet.csv
    * **UnalignedPath** - Unaligned/
    * **RunType** - hiseq or miseq
    * **RunDir** - Unaligned/

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

In the case of dual barcodes (i5 and i7) barcodes, please use the following script to create the samplesheet.
```
create_samplesheet_miseq_i5_i7.R
USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>
```

Rename fastqs
```
fastqs_rename.R
Error: USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>
```
* **FlowcellID** - flowcell number, e.g. 351
* **NumberOfFiles** - 2 (if there are two *.fastq.gz files inside the directory; not considering the Undetermined files)
* **SampleSheet** - 150921_M02457_0067_000000000-AJ7YY/SampleSheet.csv
* **UnalignedPath** - 150921_M02457_0067_000000000-AJ7YY/
* **RunType** - miseq
* **RunDir** - 150921_M02457_0067_000000000-AJ7YY/


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
cd /bigdata/genomics/cclark/
sudo rsync -a flowcell365/ /bigdata/genomics/shared/RunAnalysis/flowcell365
sudo chown -R root.root /bigdata/genomics/shared/RunAnalysis/flowcell365
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

Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
