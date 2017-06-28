#!/bin/bash -l

source $HTS_PIPELINE_HOME/env_profile.sh

if (($# < 1)); then
    echo "Usage: reverse_compliment.sh <SampleSheet> [barcodeColumn = 6] [printOnly = 0]"
    exit 1
fi

if (($# == 1)); then
    COLUMN_NUM=6
else
    COLUMN_NUM=$2
fi

SAMPLESHEET="$1"
TMP_SAMPLESHEET="$1.tmp"

awk -F',' -v colNum="$COLUMN_NUM" '
BEGIN {
  OFS = FS;
}

/Sample_ID/ {
  print $0;
  next
}
{
  "echo "$colNum" | rev | tr ATCG TAGC" | getline newcode;
  $colNum=newcode
  print $0
}' $SAMPLESHEET > $TMP_SAMPLESHEET

if [ "$3" == "1" ]; then
    cat "$TMP_SAMPLESHEET"
    rm -f "$TMP_SAMPLESHEET"
else
    rm -f $SAMPLESHEET
    mv $TMP_SAMPLESHEET $SAMPLESHEET
fi

