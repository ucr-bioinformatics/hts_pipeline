#!/bin/bash -l

########################
# Start HTS Pipeline #
########################

echo "started running"

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

# Change directory to source
SOURCE_DIR='/bigdata/genomics/shared/Runs'
cd $SOURCE_DIR

# Get list of Run directories
dir_list=`find . -maxdepth 1 -type d`
# Iterate over each Run directory
for dir in $dir_list; do
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Find sample sheet
        complete_file=`find $dir -name RTAComplete.txt`

        if [ ! -z $complete_file ]; then
            # Determine flowcell ID
            FC_ID=`echo $dir | cut -dl -f4`

            # Send email notification
            echo "Sending Mail"
            /usr/sbin/sendmail -vt << EOF
To: hts@biocluster.ucr.edu
From: no-reply@biocluster.ucr.edu
Subject: HTS Pipeline: Flowcell $FC_ID: Started

Flowcell $FC_ID has come in and needs to be processed.
Thanks
EOF
            echo "Processing $FC_ID" >> $HTS_PIPELINE_HOME/log/miseq_pipeline.log
            echo \"miseq_start.sh $SOURCE_DIR \" | qsub -l nodes=1:ppn=4,mem=10gb -j oe -o $HTS_PIPELINE_HOME/log/miseq_start.log -m bea -M hts@biocluster.ucr.edu
            #echo \"miseq_start.sh $SOURCE_DIR \" | qsub -l walltime=00:10:00 -j oe -o $HTS_PIPELINE_HOME/log/miseq_start.$PBS_JOBID.log
        fi
    fi
done

#########################
# Start HiSeq Pipeline? #
#########################

exit $?
