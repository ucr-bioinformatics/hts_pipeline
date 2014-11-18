#!/bin/bash

#############################################
# Check for MiSeq data and execute pipeline #
#############################################

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

# Check Arguments
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {/path/to/source}"
  exit $E_BADARGS
fi

# Change directory to source
SOURCE_DIR=$1
cd $SOURCE_DIR

# Check for SampleSheet
sample_sheet=$2

if [ -f $sample_sheet ]; then
    # Determine sequencer run directory
    run_dir=`dirname $sample_sheet`
    dir=`dirname $run_dir`
    run_dir=`echo $run_dir | cut -d/ -f 3`
    
    # Set lock file
    lockfile -r 0 $dir/miseq_start.lock || ( echo "Could not create $dir/miseq_start.lock" && exit 1 )

    # Determine flowcell ID
    FC_ID=`echo $dir | cut -dl -f4`

    # Set error file
    ERROR=0
    export ERROR_FILE=$SHARED_GENOMICS/$FC_ID/error.log
    mkdir -p $SHARED_GENOMICS/$FC_ID
    echo "Starting Pipeline" > $ERROR_FILE
    
    ##################
    # Pipeline Steps #
    ##################
    
    # Transfer miseq data
    if [ $ERROR -eq 0 ]; then
        echo -e "==== RSYNC STEP ====\nrsync_miseq_data.sh $FC_ID $SOURCE_DIR/$dir" >> $ERROR_FILE
        rsync_miseq_data.sh $FC_ID $SOURCE_DIR/$dir &>> $ERROR_FILE
        if [ $? -eq 0 ]; then
            rmdir $SOURCE_DIR/$dir/$run_dir && rmdir $SOURCE_DIR/$dir
        else
            echo "ERROR:: Rsync transfer failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Create Sample Sheet
    if [ $ERROR -eq 0 ]; then 
        echo -e "==== SAMPLE SHEET STEP ====\ncreate_samplesheet_miseq.R $FC_ID SampleSheet.csv $run_dir" >> $ERROR_FILE
        create_samplesheet_miseq.R $FC_ID SampleSheet.csv $run_dir &>>$ERROR_FILE || 
        (echo "ERROR: SampleSheet creation failed" >> $ERROR_FILE && ERROR=1)
    fi

    # Rename Files
    if [ $ERROR -eq 0 ]; then 
        echo -e "==== RENAME STEP ====\nfastqs_rename.R $FC_ID 3 $run_dir/SampleSheet.csv $run_dir miseq $run_dir" >> $ERROR_FILE
        fastqs_rename.R $FC_ID 2 $run_dir/SampleSheet.csv $run_dir miseq $run_dir &>>$ERROR_FILE ||
        (echo "ERROR: Files rename failed" >> $ERROR_FILE && ERROR=1)
    fi

    # Generate QC report
    if [ $ERROR -eq 0 ]; then
        PAIR=1
        MUX=2
        echo -e "==== QC STEP ====\nqc_report_generate_targets.R $FC_ID $PAIR $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/$run_dir/SampleSheet.csv $MUX" >> $ERROR_FILE
        qc_report_generate_targets.R $FC_ID $PAIR $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/$run_dir/SampleSheet.csv $MUX &>>$ERROR_FILE ||
        (echo "ERROR: QC report generation failed" >> $ERROR_FILE && ERROR=1)
    fi

    # Update Illumina web server URLs
    if [ $ERROR -eq 0 ]; then 
        echo -e "==== URL STEP ====\nsequence_url_update.R $FC_ID 1 $SHARED_GENOMICS/$FC_ID" >> $ERROR_FILE
        sequence_url_update.R $FC_ID 1 $SHARED_GENOMICS/$FC_ID &>>$ERROR_FILE ||
        (echo "ERROR: Illumina URL update failed" >> $ERROR_FILE && ERROR=1)
    fi

    # Remove lock files
    rm -f $SHARED_GENOMICS/$FC_ID/miseq_start.lock
fi

# Exit
exit $ERROR

