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
    # <FlowcellID> flowcell number
    # <Samplesheet> Excel sheet given by John
    # <Rundir>  /home/researchers/RunAnalysis/flowcell322/150514_SN279_0465_BC64T6ACXX/
    ```

CASAVA
======
1. Run CASAVA
On the HTS systen, go to /home/casava_fastqs/flowcellnum/ and run the following:
    ```
    /opt/bcl2fastq/1.8.4/bin/configureBclToFastq.pl --input-dir /home/researchers/RunAnalysis/flowcell338/150715_SN279_0478_AC7T7YACXX/Data/Intensities/BaseCalls --sample-sheet /home/researchers/RunAnalysis/flowcell338/150715_SN279_0478_AC7T7YACXX/Data/Intensities/BaseCalls/SampleSheet.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/casava_fastqs/338/Unaligned
    cd Unaligned/
    nohup make -j 8
    ```
   
Note: inside Unaligend/ directory, check inside the Basecall_Stats_C7T7YACXX directory for the file "Demultiplex_Stats.htm"; if present, the casava process has run normally. Also check for nohup.out file for any errors. 

2. Copy SampleSheet from BaseCalls to FASTQs directory (besides the Unaligned output)

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
    * **Demultiplex type** - 1 for CASAVA, 2 if user will demultiplex
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

Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
