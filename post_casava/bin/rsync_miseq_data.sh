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
rsync -a --progress --remove-source-files $SOURCE_FC/ $SHARED_GENOMICS/$FC_ID
echo "...Transfer Complete"

