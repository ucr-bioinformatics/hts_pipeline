Illumina HiSeq Pipeline 
=======================

Running
-------------------------

1. Email request from John, asking if he can start new flowcell.
1. Check Runs space
    ~~~~~~~
    ssh nkatiyar@hts.ucr.edu
    enter password
    ~~~~~~~~

    Check the space using df. The sequencing instrument copys the data in real time to /home/researchers/Runs/. This folder is a shared network drive (Z:) on the sequencing instrument.
    ~~~~~~~~
    [nkatiyar@hts illumina_runs]$ df
        Filesystem                      1K-blocks   Used        Available   Use% Mounted on
        /dev/mapper/vg00-lvRoot         4062912     1274840     2578360     34% /
        /dev/mapper/vg00-lvVar          6094400     1799812     3980016     32% /var
        /dev/mapper/vg00-lvOpt          6094400     3852376     1927452     67% /opt
        /dev/mapper/vg00-lvTmp          41293072    152128      39009832     1% /tmp
        /dev/mapper/vg00-lvUsr          10157368    5217340     4415740     55% /usr
        /dev/cciss/c1d0p1               202219      66474       125305      35% /boot
        tmpfs                           16415112    0           16415112     0% /dev/shm
        /dev/mapper/vg01-lvHome         16824100464 11600559600 4766101060  71% /home
        /dev/mapper/vg02-lvResearchers  19534684160 14134585132 5400099028  73% /home/researchers
        /dev/sda2                       951111700   130576344   772221604   15% /mnt/sda
    ~~~~~~~~
    The /home filesystem is where the illumina_runs direcotry is located (/home/www/html/illumina_runs/). CASAVA stores the generated FASTQ files here. The /home/researchers filesystem is where the RunAnalysis direcotrty is located (/home/researchers/RunAnalysis). The sequencer generates intensity and bcl files here. When John asks about available space on the Z dirve, he is referring to the /home/researchers filesystem. A paired end run can be 1.5 TB to 3 TB. In general it is bad to have usage over 80%. So, you must delete old intensity files and bcl files, to free up space so that John can run the new flowcell.
    ~~~~~~~~
    rm -rf /home/researchers/RunAnalysis/flowcell206/130912_SN279_0378_AC2C1DACXX/Data/Intensities/BaseCalls
    ~~~~~~~~
    Check the /home/reaserchers filesystem for capacity
    ~~~~~~~~
    df -h  /home/researchers #no more than 80%
    Filesystem                     Size  Used Avail Use% Mounted on
    dev/mapper/vg02-lvResearchers  19T   14T  5.0T  74% /home/researchers
    ~~~~~~~~

    You should delete the intensity files for old flowcells. We only keep them for a period of one month, starting from when you sent the email notification to the user regarding the availabilty of their FASTQs.
    
    __Overview of sizes__
    
      Cycles             |     Size     |            Observed
-----------------------  | ------------ | ---------------------------------
2X101X7 cyles flowcell   | 1.5 TB space | (My experience (Neerja) – 3.0 TB)
1X101X7 cycles flowcell  | 1 TB space   | (My exp (Neerja) – 1.5 TB)
50X7 cycles flowcell     | 0.5 TB space | (My exp (Neerja) – 1 TB)

    If the requested run potentially consumes enough space to push capacity beyond 80%, then you must delete and/or archive past runs. In order to do this, you might have to email John to notify him that you are freeing up space. Once it is determined that there is enough space for the next run, notify John that he may proceed.
    
    Sometimes Illumina submits software updates to the instrument and they may ask you to setup the network drive (Z:) on the sequencer controller Windows system. You can ask the IIGB system administrator (Jordan) for help with this. Refer to the manual how to set the network drive http://support.microsoft.com/kb/308582
    
1. After the run has started you will need to create the hiseqviewer (realtime viewer) link. This is to allow the progress of the sequencing run to be checked online (http://illumina.ucr.edu/illumina_runs/realtimeview/). Create hiseqviewer link in the /home/www/html/illumina_runs/realtime folder:
    ```
    cd /home/www/html/illumina_runs/realtimeview
    ln -s /home/researchers/Runs/130611_SN279_0357_AC26TAACXX/ flowcell192
    ```
    Old links can be removed:
    ```
    cd /home/www/html/illumina_runs/realtimeview/
    ls
101130_SN279_0151_B80UUUABXX_test  FC115_realtime  FC148_realtime      flowcel133_new_realtime	flowcell143_realtime	flowcell168_realtime  flowcell189
130314_SN279_0336_AH0BJ2ADXX	   FC116_realtime  FC149_realtime      flowcell105		flowcell144_realtime	flowcell169_realtime  flowcell190
130315_SN279_0337_BH0BGEADXX	   FC117_realtime  FC150_realtime      flowcell116		flowcell152_realtime	flowcell170_realtime  flowcell191
Data				   FC118_realtime  FC151_realtime      flowcell124_realtime	flowcell153_realtime	flowcell171_realtime  flowcell192
FC100_realtime			   FC119_realtime  FC86_B_SE_realtime  flowcell125_realtime	flowcell154_realtime	flowcell172_realtime  flowcell193
FC101_realtime			   FC120_realtime  FC88_realtime       flowcell126		flowcell155_realtime	flowcell173_realtime  flowcell194
FC102_realtime			   FC121_realtime  FC89_realtime       flowcell126_realtime	flowcell156_B_realtime	flowcell174_realtime  flowcell195
FC103_realtime			   FC122_realtime  FC90_B_SE_realtime  flowcell126_runFolder	flowcell156_realtime	flowcell175_realtime  flowcell196
FC104_realtime			   FC123_realtime  FC91		       flowcell127		flowcell157_realtime	flowcell176_realtime  flowcell197
FC105_realtime			   FC129_demulti   FC91_realtime       flowcell127run		flowcell158_realtime	flowcell177_realtime  flowcell198
FC106_realtime			   FC129_realtime  FC92_realtime       flowcell128		flowcell159_realtime	flowcell178_realtime  flowcell201
FC107_realtime			   FC131_realtime  FC93_realtime       flowcell128run		flowcell160_realtime	flowcell179_realtime  flowcell202
FC108_realtime			   FC137_realtime  FC94_realtime       flowcell130_realtime	flowcell161_realtime	flowcell182	      flowcell205
FC109_realtime			   fc_138	   FC95_realtime       flowcell134_realtime	flowcell162_realtime	flowcell183	      flowcell206
FC110_realtime			   FC141_realtime  FC96_realtime       flowcell135_realtime	flowcell163_realtime	flowcell184_realtime  newFC136_realtime
FC111_realtime			   FC142_realtime  FC97_realtime       flowcell136_realtime	flowcell164_realtime	flowcell185_realtime
FC112_realtime			   FC145_realtime  FC98_realtime       flowcell138_realtime	flowcell165_realtime	flowcell186_realtime
FC113_realtime			   FC146_realtime  FC99_realtime       flowcell139_realtime	flowcell166_realtime	flowcell187
FC114_realtime			   FC147_realtime  flowceell132        flowcell140_realtime	flowcell167_realtime	flowcell188
    ```

    We can go to this link to check the status of the sequence run:
    >username: realtimeuser
    
    >password: hiseqviewer
    
    >http://hts.ucr.edu/illumina_runs/realtimeview/

1. John will send an email to you, once the sequencing has completed. Verify completion by checking if RTAComplete.txt file is present in run directory:
    ```
    ls -la /home/researchers/Runs/140207_SN279_0394_BC3UPCACXX/RTAComplete.txt
    -rwxrwxr-x 1 researchers researchers 47 Feb 10 11:10 /home/researchers/Runs/140207_SN279_0394_BC3UPCACXX/RTAComplete.txt
    ```

CASAVA
-------
1. After the sequencing finish, move /13**/folder from Runs folder to RunsAnalysis folder for running CASAVA.
    1. Create directory for new flowcell under /home/researchers/RunAnalysis/
        ```
        cd /home/researchers/RunAnalysis/
        mkdir flowcell192
        cd flowcell192
        ```
    1. Then move flowcell run folder (e.g, 130611_SN279_0357_AC26TAACXX) from  “Runs” folder to new flowcell folder “RunAnalysis” folder:
        ```
        mv /home/researchers/Runs/130611_SN279_0357_AC26TAACXX/ .
        ```

    Then John will not be able to see the raw data for that flowcell as we have already moved to RunsAnalysis folder. Since John might need the raw data for SAV (Sequence Analysis folder), so create another symbolic link to the RunsAnalysis folder so that he can access the raw data. SAV doesn’t need intensity file and bcl files.

1. Create the SampleSheet.csv file in run folder. Please see more details in CASAVA manual
    ```
    cd /home/researchers/RunAnalysis/flowcell192/130605_SN279_0356_BD268JACXX/
    ```

    For creating sample sheet, we could refer to John’s email containing the flowcell information and check if the barcodes are given. Sometimes, when John doesn’t know the barcodes, we can ask the user for barcodes directly through email.
    ```
    Lane 2            RIL Lib 92-228, Wessler                  TruSEQ DNA, Indices:  20, 22, 15, 25, 2, 7, 8, 9, 5, 10, 12, and 13
    ```
    In the above case, we could use the script Truseq.R in the directory /home/researchers/scripts/ to create the SampleSheet.

    Below is an example of a different samplesheet.
    ```
    vim SampleSheet.csv
 
    FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
    D268JACXX,1,1,,CAGATC,,N,,rsun,578
    D268JACXX,1,2,,ACTTGA,,N,,rsun,578
    D268JACXX,1,3,,GATCAG,,N,,rsun,578
    D268JACXX,1,4,,TAGCTT,,N,,rsun,578
    ```
    
    It will be different in this case.
    ```
    Lane 3            CottonBAC201307, Roberts              These aren't TruSEQ; they will demultiplex
    ```
    
    We cannot use TrueSeq.R script or TruSEQ.txt to generate Samplesheet. The user will do demultiplexing themselves. We cannot use TrueSeq.txt for non-illumina (aren’t TruSEQ). Samplesheet related to Lane 3 should not include barcode information.

    Just create 2 fastq files for single end:
    
    1. Genomic sequence
    2. Barcode

    For the paired end, there are 3 files:
    
    1. Genomic sequence 1
    2. Barcode
    3. Genomic sequence 2

1. Create an output folder of FASTQ file in /home/www/html/illumina_runs/ 
    ```
    mkdir /home/www/html/illumina_runs/192/
    ```
    Before running CASAVA, check the space using df to ensure that /home (/home/www/html/illumina_runs/) has enough space.

1. Next run CASAVA using different parameters.
    * To run CASAVA for lane with demultiplexing (Barcode)
    ```
    /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/189/Unaligned
    ```
    * To run CASAVA for lane without demultiplexing (No barcode)
    ```
/home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet2.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/205/Unaligned2 --use-bases-mask Y*,Y*
    ```
    In the above command, we have used 2 Y’s for single-end and 3 Y’s (--use-bases-mask Y*,Y*,Y*) for paired end.

    To run CASAVA from Rebecca’s directory, try the following.
    ```
    sudo su – rsun
    ```
    Go to Unaligned folder under flowcell:
    ```
    cd /home/researchers/RunAnalysis/flowcell206/130912_SN279_0378_AC2C1DACXX/Unaligned
    ```
    Use screen so that long running processes are not interupted:
    ```
    screen
    ```
    Run CASAVA by executing the make commad with how many CPU cores you want to use:
    ```
    make –j 8
    ```

    __Test Runs Examples__
    
    1. For barcode samplesheet
    2. For lane only samplesheet

    Example 1: test
    
    Samplesheet example here
    ```
    FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
    C2C1DACXX,5,lane5,,,,N,,nkatiyar,640
    ```
    
    Example 2: test1
    
    Samplesheet example here (/home/www/html/illumina_runs/206/test1/Project_638/Sample_1)
    ```
    FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
    C2C1DACXX,2,1,,ATCACG,,N,,rsun,638
    ```
    
    Use sudo to run CASAVA
    ```
    sudo /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet1.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/206/test1
    
    sudo make –j 2
    ```
    
    Samplesheet 2
    ```
    FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
    C2C1DACXX,5,lane5,,,,N,,nkatiyar,640
    ```
    
    ```
    sudo /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet2.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/206/test2 --use-bases-mask Y*,Y*
    ```

    Example 3: test3
    ```
    screen –r (recover the screen)
    There are several suitable screens on:
	24811.pts-10.hts	(Detached)
	11688.pts-10.hts	(Detached)
	27117.pts-10.hts	(Detached)
    Type "screen [-d] -r [pid.]tty.host" to resume one of them.
    ```

1. Upload FASTQ files
    Gp tp flowcell folder:
    ```
    cd /home/www/html/illumina_runs/189
    ```
    Manually edit script in relevant locations to support paried end or single end run:
    ```
    vim /home/researchers/scrpts/movedemulitplex.R
    ```
    Change username from root to nkatiyar of the Unaligned folder
    ```
    sudo chown -R nkatiyar Unaligned/  # Don’t need this step anymore if not using sudo while running CASAVA
    ```
    Move the fastq.gz files from /home/www/html/illumina_runs/206/test2/Project** to /home/www/html/illumina_runs/206/
    >Important: Copy Samplesheet2 to this folder /home/www/html/illumina_runs/206/ 

    Then you need run the script move_demultiplexing.R and mention the samplesheet directory. By default it uses current directory. It moves the data and changes all the fastq.gz file names, from CASAVA format to our format. CASAVA generates lane5_Noindex_L005_R1_001.fastq.gz file name. We give user the file with name similar to flowcell206_lane*_ACCCTG.fastq.gz output file. We use this format flowcell206_lane*_pair*_barcode.fastq.gz for naming file.
    ```
    cd /home/www/html/illumina_runs/206/
    R CMD BATCH --no-save /home/researchers/scripts/movedemulitplex.R
    ```

1. After you are done running CASAVA for all lanes for this flowcell, then we ask Jordan to copy the fastq files for this flowcell to illumina.bioinfo.ucr.edu. HTS stores fastq files temporarily. So, we delete the fastq files when it gets full after one or two months. Illumina.bioinfo.ucr.edu is a big server, so that we can store all the files. We tell customers that we have files only for a year, although we have kept all of the run folders, excluding the deleted BCL files. Jordan will send email that copying is finished. Then we can create the link for fastq file for the server.
Individuals are now able to do this via the rsync_illumina_data.sh script:
    1. Log onto the hts server 
    ```
    sudo su –
    ```
    2. Use screen
    ```
    screen
    ```
    3. Run rsync
    ```
    rsync_illumina_data.sh 211

    Starting 211...
    sending incremental file list

    sent 147726 bytes  received 74 bytes  98533.33 bytes/sec
    total size is 100972172139  speedup is 683167.61
    ...Transfer Complete
    ```
    (Ask Jordan to rsync all the fastq files for that flowcell to illumina.bioinfo.ucr.edu. After this Jordan will email that it is finished. I can also check if rsync is finished on HTS server by using top.)

1. Create the qc link
    ```
    ln -s Unaligned/Basecall_Stats_D268JACXX/ qc
    ```

    If there are diffrent cases for samplesheet, then we will have multiple unaligned folders eg. Unaligned, Unaligned1. You will have to add qc links manually on the website. Go to the database to change the qc link directly.

1. Generate HTML links for illumina.bioinfo.ucr.edu
    1. Log onto illumina
    ```
    ssh illumina
    2. Change flowcell ID in this script and then run the R script.
    ```
    vim sequence_url_update.R
    ```
    3. Run script
    ```
    R CMD BATCH --no-save sequence_url_update.R
    ```
    4. Go to illumina website to check if the link is created for that flowcell. After confirming everything is fine, you can send a common email to all the users of that flowcell and John and Glen, that the data is available.

Database
--------
Modifying the database manually Phpmyadmin interface maybe needed:
> http://illumina.ucr.edu/ddbqP3QSHyOEEL6V0wckonxMzGmrLr3/

1. Log onto the illumina server
```
ssh nkatiyar@illumina
```
2. Go to the directory and run this script:
```
/etc/init.d/mysql stop
```
3. Create a bakcup copy of the database:
```
cp -r /var/lib/mysql/db_name_copy /some/other/location
```
4. To start the database again:
```
/etc/init.d/mysql start
```
5. Navigate in your internet browser to the item and change the value of qc link.
    For example:
    http://illumina.bioinfo.ucr.edu/ht/download/project_summary?project_id=644
    All the coresponding links within the column "Sequence Quality" need to be altered to reflect the correct qc link.

Additional Notes
================
Set Cron
--------
http://en.wikipedia.org/wiki/Cron
http://kvz.io/blog/2007/07/29/schedule-tasks-on-linux-using-crontab/

Information
-----------
http://illumina.bioinfo.ucr.edu/ht/documentation/analysis

http://manuals.bioinformatics.ucr.edu/home/ht-seq

https://www.dropbox.com/sh/a9ye9rreapjg8sc/7iUa1X0ejv

http://manuals.bioinformatics.ucr.edu/home/ht-seq

http://manuals.bioinformatics.ucr.edu/workshops/dec-6-10-2012

OLB
---
Offline basecaller to call the base
Sequencing instrument will 

http://support.illumina.com/sequencing/sequencing_software/offline_basecaller_olb.ilmn

Manual for OLB files
--------------------
http://supportres.illumina.com/documents/myillumina/ec3129a6-b41f-4d98-963f-668391997f1a/olb_194_userguide_15009920d.pdf

Source
------
The original source of this content is from Rebecca's Google drive.
Since significant changes in the pipeline are underway, Rebecca should no longer be consulted.

