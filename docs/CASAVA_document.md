Illumina HiSeq Pipeline 
=======================

Running
-------------------------

1. We get email from John to ask you if he can start new flowcell.
1. Then we will check space as following.
1. ssh to hts.ucr.edu
~~~~~~~
        ssh nkatiyar@hts.ucr.edu
        enter password
~~~~~~~~

1. Check the space using df. Check space of the /home/researchers folder and delete the oldest flowcell folder.
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
    The /home filesystem is where the illumina_runs direcotry is located (/home/www/html/illumina_runs/). CASAVA stores the generated FASTQ files here. The /home/researchers filesystem is where the RunAnalysis direcotrty is located (/home/researchers/RunAnalysis). The sequencer generated intensity and bcl files are stored here. When John asks about available space on the Z dirve, he is referring to the /home/researchers filesystem. A paired end run can be 1.5 TB to 3 TB. In general it is bad to have usage over 80%. So, you must delete old intensity files and bcl files, to free up space so that John can run the new flowcell.
~~~~~~~~
    [nkatiyar@hts BaseCalls]$ pwd
    /home/researchers/RunAnalysis/flowcell206/130912_SN279_0378_AC2C1DACXX/Data/Intensities/BaseCalls
~~~~~~~~
    Rebecca Google Drive /Illumina%20Pipeline%20Running%20and%20Server%20Maintenance%20Document.doc 
~~~~~~~~
    $df -h  #no more than 80%  for /home/researchers
~~~~~~~~

    You should delete the intensity files for old flowcells. We only keep them for a period of one month, starting from when you sent the email notification to the user regarding the availabilty of their FASTQs. 

    __Pracital Sizes__
    >2X101X7 cyles flowcell | ~1.5 TB space | (My experience (Neerja) – 3.0 TB)
    >1X101X7 cycles flowcell | ~1 TB space | (My exp (Neerja) – 1.5 TB)
    >50X7 cycles flowcell | 0.5 TB space | (My exp (Neerja) – 1 TB)


1. John will run sequencing and will ask to create realtime view link or hiseq viewer link for him. So that John can check the process of sequencing online.
http://illumina.ucr.edu/illumina_runs/realtimeview/

~~~~~~~~
    [nkatiyar@hts illumina_runs]$ pwd
        /home/www/html/illumina_runs
    [nkatiyar@hts illumina_runs]$ cd realtimeview/
    [nkatiyar@hts realtimeview]$ ls
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
~~~~~~~~
    The sequencing instrument copy the data to /home/researchers/Runs/ This is real time copy.

Reply to John he can start. When he starts, he will ask to create hiseqviewer (realtime viewer) link to him.

Create hiseqviewer link in the /home/www/html/illumina_runs/realtime folder
Go to /home/www/html/illumina_runs/realtimeview
$ln -s /home/researchers/Runs/130611_SN279_0357_AC26TAACXX/ flowcell192

This was for internet browser (http) access.
/home/researchers/Runs/ folder is a network drive of sequencing instrument

So that sequencing instrument can access the Runs on hts server
So that sequencing instrument can copy all the raw data to Runs on hts server
since John needs see the process of copying
http://illumina.ucr.edu/ is a web link we can access the hts server
so we put a symbolic link for Runs folder under illumina.ucr.edu/illumina_runs/realtimeviewer link so John can access the Runs folder of new flowcell through illumina.ucr.edu/illumina_runs/realitme/ link

We can go to this link to check if the sequencing is completed.
http://illumina.ucr.edu/illumina_runs/realtimeview/
username: realtimeuser
password:hiseqviewer

1)	John will send email to you that sequencing is complete.
2)	Check if RTA_Complete file is present in 130__.........ABCXFF___ folder.

How the sequencing instrument can copy the data to Runs folder? It is not related to CASAVA running. It is about Illumina output folder structure.

So that sequencing instrument can access the Runs folder on hts server
So that sequencing instrument can copy all the raw data to Runs on hts server
since John needs see the process of copying
http://illumina.ucr.edu/ is a web link we can access the hts server
so we put a symbolic link for Runs folder under illumina.ucr.edu/illumina_runs/realtimeviewer link so John can access the Runs folder of new flowcell through illumina.ucr.edu/illumina_runs/realitme/ link

Sometimes, Illumina company updates the instrument and they will ask to setup the network drive in windows system. I can ask Jordan for help with this.
Refer to the manual how to set the network drive http://support.microsoft.com/kb/308582

Step 2: Go to /home/researchers/RunAnalysis/
cd /home/researchers/RunAnalysis/

Step 3: Create directory for new flowcell (eg. Flowcell 192)
mkdir flowcell192

Step 4: Enter the flowcell directory
cd flowcell192

Step 5: Move flowcell run folder (e.g, 130611_SN279_0357_AC26TAACXX) from  “Runs” folder to “RunAnalysis” folder
mv /home/researchers/Runs/130611_SN279_0357_AC26TAACXX/ .

After the sequencing finish. you need mv /13**/folder from Runs folder to RunsAnalysis folder for running CASAVA
Then John will not be able to see the raw data for that flowcell as we have already moved to RunsAnalysis folder. Since John might need the raw data for SAV (Sequence Analysis folder), so I will create another symbolic link to the RunsAnalysis folder so that he can access the raw data.
SAV doesn’t need intensity file and bcl files.

Step 6: Create the SampleSheet.csv file in run folder. Please see more details in CASAVA manual
$cd /home/researchers/RunAnalysis/flowcell192/130605_SN279_0356_BD268JACXX/

For creating sample sheet, we could refer to John’s email about flowcell and check if the barcode is given. Sometimes, when John doesn’t know the barcode, we can ask the user for barcode directly through email.

Eg. 
Lane 2            RIL Lib 92-228, Wessler                  TruSEQ DNA, Indices:  20, 22, 15, 25, 2, 7, 8, 9, 5, 10, 12, and 13

In the above case, we could use the script Truseq.R in the directory /home/researchers/scripts/ to create the SampleSheet.

Below is an example of a different samplesheet.

$ vim SampleSheet.csv
e,g 
FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
D268JACXX,1,1,,CAGATC,,N,,rsun,578
D268JACXX,1,2,,ACTTGA,,N,,rsun,578
D268JACXX,1,3,,GATCAG,,N,,rsun,578
D268JACXX,1,4,,TAGCTT,,N,,rsun,578

It will be different in this case.
Lane 3            CottonBAC201307, Roberts              These aren't TruSEQ; they will demultiplex

We cannot use TrueSeq.R script or TruSEQ.txt to generate Samplesheet. The user will do demultiplexing by themselves. We cannot use TrueSeq.txt for non-illumina (aren’t TruSEQ). Samplesheet related to Lane 3 should not include barcode information.

Just create 2 fastq files for single end 1) Genomic sequence 2) Barcode

For the paired end, there 3 files 1) Genomic sequence 1 2) Barcode 3) Genomic sequence 2

Step 7: Create an output folder of FASTQ file in /home/www/html/illumina_runs/ 
$mkdir /home/www/html/illumina_runs/192/

Before running CASAVA, check the space using df to check home which shows result of (/home/www/html/illumina_runs/)

Step 8: Next run CASAVA using different parameters.

1) Barcode
$ /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/189/Unaligned

2) No barcode
To run CASAVA for lane without demultiplexing
/home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet2.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/205/Unaligned2 --use-bases-mask Y*,Y*

In the above command, we have used 2 Y’s for single-end and 3 Y’s (--use-bases-mask Y*,Y*,Y*) for paired end.

To run CASAVA from Rebecca’s directory, try the following.
sudo su – rsun

Go to /home/researchers/RunAnalysis/flowcell206/130912_SN279_0378_AC2C1DACXX/Unaligned

Use screen

Then make –j 8

Test runs

1)	For barcode samplesheet
2)	For lane only samplesheet

Insert related samplesheets

Example 1: test

Samplesheet example here

FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
C2C1DACXX,5,lane5,,,,N,,nkatiyar,640

Example 2: test1

Samplesheet example here (/home/www/html/illumina_runs/206/test1/Project_638/Sample_1)

FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
C2C1DACXX,2,1,,ATCACG,,N,,rsun,638

Use sudo to run CASAVA

[nkatiyar@hts 130912_SN279_0378_AC2C1DACXX]$ sudo /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet1.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/206/test1

sudo make –j 2

Samplesheet 2

FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
C2C1DACXX,5,lane5,,,,N,,nkatiyar,640

1) 
sudo /home/rsun/illuminasoftware/CASAVA-1.8.2/bin/configureBclToFastq.pl --input-dir Data/Intensities/BaseCalls/ --sample-sheet SampleSheet2.csv --fastq-cluster-count 600000000 --ignore-missing-stats --output-dir /home/www/html/illumina_runs/206/test2 --use-bases-mask Y*,Y*

Example 3: test3

[nkatiyar@hts ~]$ screen –r (recover the screen)
There are several suitable screens on:
	24811.pts-10.hts	(Detached)
	11688.pts-10.hts	(Detached)
	27117.pts-10.hts	(Detached)
Type "screen [-d] -r [pid.]tty.host" to resume one of them.

screen –r processed

Step 9: Upload FASTQ files
$ cd /home/www/html/illumina_runs/189

Step 10: Config “/home/researchers/scrpts/movedemulitplex.R” for paired_end or single_end run

Important step: Change username from root to nkatiyar of the Unaligned folder
[nkatiyar@hts 209]$ sudo chown -R nkatiyar Unaligned/ ( don’t need this step anymore if not using sudo while running CASAVA)

Step 11: To move the fastq.gz from /home/www/html/illumina_runs/206/test2/Project** to /home/www/html/illumina_runs/206/
Important: Copy Samplesheet2 to this folder /home/www/html/illumina_runs/206/ 

Step 12: Then you need run the script move_demultiplexing.R and mention the samplesheet directory. By default it uses current directory. It moves the data and changes the name, change name from CASAVA format to our format
CASAVA generates lane5_Noindex_L005_R1_001.fastq.gz file name.
We give user the file with name similar to flowcell206_lane*_ACCCTG.fastq.gz output file.
We use this format flowcell206_lane*_pair*_barcode.fastq.gz for naming file.

Move fastq files from de-multiplexing folder to downloading folder eg. 189 folder 
$ R CMD BATCH --no-save /home/researchers/scripts/movedemulitplex.R

the owner from root to your name
/home/researchers/scripts/movedemulitplex.R
R CMD BATCH --no-save /home/reseeacher/script/movedemulitple.R

Example script: 

pairs <-c("R1","R2")## c("R1") for single-end c{"R1","R2") for paired-end, c("R1","R2",R3) for three reads
flowcell <-"flowcell206"
wwwpath <-"/home/www/html/illumina_runs/206/"
samples <-read.csv("SampleSheet2.csv")
project <- samples$SampleProjectsamplenumber <-samples$SampleID
index <-samples$Index
lane <-samples$Lane

for(i in 1:length(samples[,1])){
defiles <-paste("test2/","Project_",project[i],"/","Sample_",samplenumber[i],"/",samplenumber[i],"_", "NoIndex","_", "L00",lane[i],"_",pairs[1], "_", "*.fastq.gz", sep
="")     
commands <-system(paste("mv ",defiles, "  ",wwwpath, flowcell, "_lane",lane[i],"_pair1",".fastq.gz",sep=""))
         
defiles <-paste("test2/","Project_",project[i],"/","Sample_",samplenumber[i],"/",samplenumber[i],"_", "NoIndex","_", "L00",lane[i],"_",pairs[2], "_", "*.fastq.gz", sep
="")
       
commands <- system(paste("mv ",defiles, "  ",wwwpath, flowcell, "_lane",lane[i],"_pair2",".fastq.gz",sep=""))
}

Step 13: After you are done running CASAVA for all lanes for this flowcell, then we ask Jordan to copy the fastq files for this flowcell to illumina.bioinfo.ucr.edu
HTS stores fastq files temporarily. So, we delete the fastq files when it gets full after one or two months. Illumina.bioinfo.ucr.edu is a big server, so that we can store all the files. We tell customers that we have files only for a year, although we have all the data.

Jordan will send email that copying is finished. Then we can create the link for fastq file for the server.

Step 14: Create the qc link
ln -s Unaligned/Basecall_Stats_D268JACXX/ qc

If diff cases for samplesheet, then we will have multiple unaligned folder eg. Unaligned, Unaligned1. I should change the qc link manually on the website. Go to the database to change the qc link directly.

Database
Modify database manually Phpmyadmin interface

 http://illumina.ucr.edu/ddbqP3QSHyOEEL6V0wckonxMzGmrLr3/

Ask Jordan for the username and password of the database.

1)	Log onto the illumina folder with my account and then sudo su-
Go to the directory and run this script: nkatiyar@illumina:/var/lib$ /etc/init.d/mysql stop

2)	Location of database : /var/lib/mysql So copying the folder to a folder db_name_copy

3)	To start the database again : nkatiyar@illumina:/var/lib$ /etc/init.d/mysql stop
4)	

Go to the item and change the value of qc link. http://illumina.bioinfo.ucr.edu/ht/download/project_summary?project_id=644 (Sequence Quality) IF another folder, qc1 then replace qc by qc1.

Log onto the hts server 
Next, login as root [nkatiyar@hts ~]$ sudo su –
Use screen
[root@hts ~]# screen
[root@hts ~]# rsync_illumina_data.sh 211
Starting 211...
sending incremental file list

sent 147726 bytes  received 74 bytes  98533.33 bytes/sec
total size is 100972172139  speedup is 683167.61
...Transfer Complete

(Ask Jordan to rsync all the fastq files for that flowcell to illumina.bioinfo.ucr.edu. After this Jordan will email that it is finished. I can also check if rsync is finished on HTS server by using top.)

Step 15: To upload files on the website log on to the illumina.bioinfo.ucr.edu, run following script after making changes
nkatiyar@illumina:~$ vi sequence_url_update.R
Change flowcell ID in this script and then run the R script.
$ R CMD BATCH --no-save sequence_url_update.R

Go to illumina website to check if the link is created for that flowcell.
After confirming everything is fine, you can send email to user.

Step 16: Next, send a common email to all the users of that flowcell and John and Glen, that the data is available.

In the example use test2 folder, instead of Unaligned folder

Additional Notes:

Set Cron

http://en.wikipedia.org/wiki/Cron
http://kvz.io/blog/2007/07/29/schedule-tasks-on-linux-using-crontab/

Information

http://illumina.bioinfo.ucr.edu/ht/documentation/analysis

http://manuals.bioinformatics.ucr.edu/home/ht-seq

https://www.dropbox.com/sh/a9ye9rreapjg8sc/7iUa1X0ejv

http://manuals.bioinformatics.ucr.edu/home/ht-seq

http://manuals.bioinformatics.ucr.edu/workshops/dec-6-10-2012


[nkatiyar@hts ~]$ cd /home/www/html/illumina_runs/
[nkatiyar@hts illumina_runs]$ ls
108  113  118  123  128  133  138  142	147  152  157  162  167  172  177  181	186  191  197  202  35	       fix4.pl	for_tusar	    temp
109  114  119  124  129  134  139  143	148  153  158  163  168  173  178  182	187  193  198  203  42	       fix5.pl	illumina_fastq.txt  Unaligned1
110  115  120  125  130  135  14   144	149  154  159  164  169  174  179  183	188  194  199  204  44.tgz     fix.sh	index.html
111  116  121  126  131  136  140  145	150  155  160  165  170  175  18   184	189  195  200  205  fileslist  FORCE	makesanger.sh
112  117  122  127  132  137  141  146	151  156  161  166  171  176  180  185	190  196  201  206  fix3.pl    for_hj	realtimeview
[nkatiyar@hts illumina_runs]$

OLB – Offline basecaller to call the base.
Sequencing instrument will 

http://support.illumina.com/sequencing/sequencing_software/offline_basecaller_olb.ilmn

Manual for OLB files

http://supportres.illumina.com/documents/myillumina/ec3129a6-b41f-4d98-963f-668391997f1a/olb_194_userguide_15009920d.pdf

Go to Rebecca’s Google drive if I want to download the updated file.

