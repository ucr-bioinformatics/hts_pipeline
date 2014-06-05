#!/bin/bash -l

###########################################
# Check for MiSeq data and start pipeline #
###########################################

# Set vars
source $HTS_PIPELINE_HOME/env_profile.sh

# Make sure there is only one version of this running
lockfile -r 0 /tmp/miseq_start.lock || exit 1

# Check Arguments
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {/path/to/source}"
  rm -f /tmp/miseq_start.lock
  exit $E_BADARGS
fi

SOURCE_DIR=$1

# Change directory to source
cd $SOURCE_DIR
lockfile -r 0 miseq_start.lock || exit 1

# Get list of Run directories
dir_list=`find . -maxdepth 1 -type d`
# Iterate over each Run directory
for dir in $dir_list; do
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Find sample sheet
        sample_sheet=`find $dir -name SampleSheet.csv`

        if [ ! -z $sample_sheet ]; then
            # Determine sequencer run directory
            run_dir=`dirname $sample_sheet | cut -d/ -f 3`

            # Determine flowcell ID
            FC_ID=`echo $dir | cut -dl -f4`

            # Send email notification
            /usr/sbin/sendmail -vt << EOF
To: hts@biocluster.ucr.edu
From: no-reply@biocluster.ucr.edu
Subject: HTS Pipeline: Flowcell $FC_ID: Started

Flowcell $FC_ID has come in and needs to be processed.
Thanks
EOF

            # Set error file
            ERROR=0
            export ERROR_FILE=$SHARED_GENOMICS/$FC_ID/error.log
            mkdir -p $SHARED_GENOMICS/$FC_ID
            echo "Starting Pipeline" > $ERROR_FILE
            
            ##################
            # Pipeline Steps #
            ##################
            
            # Transfer miseq data
            if [ $ERROR -eq 0]; then
                rsync_miseq_data.sh $FC_ID $SOURCE_DIR/$dir &>>$ERROR_FILE || 
                (echo "ERROR:: Rsync transfer failed" >> $ERROR_FILE && ERROR=1)
            fi
            
            # Create Sample Sheet
            if [ $ERROR -eq 0]; then 
                create_samplesheet.R $FC_ID SampleSheet.csv $run_dir &>>$ERROR_FILE || 
                (echo "ERROR: SampleSheet creation failed" >> $ERROR_FILE && ERROR=1)
            fi

            # Rename Files
            if [ $ERROR -eq 0 ]; then 
                fastqs_rename.R $FC_ID 2 SampleSheet.csv $run_dir miseq &>>$ERROR_FILE ||
                (echo "ERROR: Files rename failed" >> $ERROR_FILE && ERROR=1)
            fi

            # Generate QC report
            if [ $ERROR -eq 0 ]; then 
                qc_report_generate_targets.R $FC_ID 2 $SHARED_GENOMICS/$FC_ID $SHARED_GENOMICS/$FC_ID $SHARED_GENOMICS/$FC_ID/SampleSheet.csv 1 &>>$ERROR_FILE ||
                (echo "ERROR: QC report generation failed" >> $ERROR_FILE && ERROR=1)
            fi

            # Update Illumina web server URLs
            if [ $ERROR -eq 0 ]; then 
                sequence_url_update.R $FC_ID 1 $SHARED_GENOMICS/$FC_ID &>>$ERROR_FILE ||
                (echo "ERROR: Illumina URL update failed" >> $ERROR_FILE && ERROR=1)
            fi

        fi
    fi
done

# Remove lock files
rm -f miseq_start.lock
rm -f /tmp/miseq_start.lock

# Exit
exit $ERROR

