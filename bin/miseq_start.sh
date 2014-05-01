#!/bin/bash

###########################################
# Check for MiSeq data and start pipeline #
###########################################

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

# Get list of Run directories
dir_list=`find . -maxdepth 1 -type d`
# Iterate over each Run directory
for dir in $dir_list; do
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Find sample sheet
        sample_sheet=`find $dir -name SampleSheet.csv`
        if [ ! -z $sample_sheet ]; then
            # Determine flowcell ID
            FC_ID=`echo $dir | cut -dl -f4`
            # Transfer miseq data
            rsync_miseq_data.sh $FC_ID $SOURCE_DIR/$dir
        fi
    fi
done
