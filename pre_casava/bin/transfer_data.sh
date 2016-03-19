#!/bin/bash

########################################################################
# Simple script to move files from Clay's upload to the shared bigdata #
########################################################################

# Check Arguments
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {FlowcellID} {/path/to/source}"
  exit $E_BADARGS
fi

# Get args
ERROR=0
FC_ID=$1
SOURCE_FC=$2

echo "Starting $FC_ID..."

# This should be modified to match the incoming file structure
mkdir $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID}
ERROR=$?

if [[ $ERROR -eq 0 ]]; then
    echo "mv $SOURCE_FC/* $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID} && rmdir ${SOURCE_FC}"
    mv $SOURCE_FC/* $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID} && rmdir ${SOURCE_FC}
    if [[ $? -eq 0 ]]; then
        echo "...Transfer Complete"
    else
        echo "ERROR:: Transfer Failed"
    fi
else
    echo "ERROR:: Could not create $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID}"
    exit $ERROR
fi

