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
FC_ID=$1
SOURCE_FC=$2

echo "Starting $FC_ID..."
# This should be modified to match the incoming file structure
echo "mv $SOURCE_FC/* $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID} && rmdir ${SOURCE_FC}"
mv $SOURCE_FC/* $SHARED_GENOMICS/RunAnalysis/flowcell${FC_ID} && rmdir ${SOURCE_FC}
echo "...Transfer Complete"

