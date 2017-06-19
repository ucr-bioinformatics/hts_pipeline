#!/bin/bash -l

source $HTS_PIPELINE_HOME/env_profile.sh

if (($# != 1)); then
    echo "Usage: reverse_compliment.sh <SampleSheet>"
    exit 1
fi

SAMPLESHEET="$1"
TMP_SAMPLESHEET="$1.tmp"

awk -F',' '
BEGIN {
  OFS = FS; found=0
}

/Sample_ID/ {
  print $0;
  found=1;
  next
}
{
  "echo "$6" | rev | tr ATCG TAGC" | getline newcode;
  $6=newcode
  print $0
}' $SAMPLESHEET > $TMP_SAMPLESHEET

rm -f $SAMPLESHEET
mv $TMP_SAMPLESHEET $SAMPLESHEET

