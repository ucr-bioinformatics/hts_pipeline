#!/bin/bash -l

source "$HTS_PIPELINE_HOME/env_profile.s"h

if (($# < 1)); then
    echo "Usage: reverse_compliment.sh <SampleSheet> [barcodeColumn = 6] [printOnly = 0]"
    exit 1
fi

SAMPLESHEET="$1"
TMP_SAMPLESHEET="$1.tmp"

# Handle the case of $SAMPLESHEET.tmp already existing by appending another .tmp
while [ -f "$TMP_SAMPLESHEET" ]; do
    TMP_SAMPLESHEET="${TMP_SAMPLESHEET}.tmp"
done
    

awk -F',' -v colNum="${COLUMN_NUM:-6}" '
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
}' "$SAMPLESHEET" > "$TMP_SAMPLESHEET"

if [ "$3" == "1" ]; then
    cat "$TMP_SAMPLESHEET"
    rm -f "$TMP_SAMPLESHEET"
else
    rm -f "$SAMPLESHEET"
    mv "$TMP_SAMPLESHEET" "$SAMPLESHEET"
fi

