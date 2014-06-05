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

            # Transfer miseq data
            rsync_miseq_data.sh $FC_ID $SOURCE_DIR/$dir
            
            ###############################################
            # Here is an example of adding pipeline steps #
            ###############################################
            #
            # Remember to eventually add proper error handling! 
            #
		
            # Create Sample Sheet
            #if [ $? -eq 0 ]; then create_samplesheet.R $FC_ID SampleSheet.csv >$ERROR_FILE; fi

            # Rename Files
            #if [ $? -eq 0 ]; then fastqs_rename.R args 2>$ERROR_FILE; fi

            # Generate QC report
            #if [ $? -eq 0 ]; then qc_report_generate.R args 2>$ERROR_FILE; fi

            # Update Illumina web server URLs
            #if [ $? -eq 0 ]; then sequence_url_update.R ards 2>$ERROR_FILE; fi

            ##############################################
        fi
    fi
done

# Remove lock files
rm -f miseq_start.lock
rm -f /tmp/miseq_start.lock

