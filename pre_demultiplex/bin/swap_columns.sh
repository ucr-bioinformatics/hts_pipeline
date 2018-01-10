#!/bin/bash -l

source "$HTS_PIPELINE_HOME/env_profile.s"h

if (($# < 1)); then
    echo "Usage: swap_columns.sh <SampleSheet> [barcodeColumn1 = 6] [barcodeColumn2 = 8] [PRINT_ONLY = 0]"
    exit 1
fi

SAMPLESHEET="$1"
TMP_SAMPLESHEET="$1.tmp"

COLUMN_NUM1="$2"
COLUMN_NUM2="$3"

PRINT_ONLY="${4:-0}"

# Handle the case of $SAMPLESHEET.tmp already existing by appending another .tmp
while [ -f "$TMP_SAMPLESHEET" ]; do
    TMP_SAMPLESHEET="${TMP_SAMPLESHEET}.tmp"
done
    

awk -F',' -v colNum1="${COLUMN_NUM1:-6}" -v colNum2="${COLUMN_NUM2:-8}" '
BEGIN {
  OFS = FS;
}

/Sample_ID/ {
  print $0;
  next
}
{
  t = $colNum1
  $colNum1 = $colNum2
  $colNum2 = t
  print $0
}' "$SAMPLESHEET" > "$TMP_SAMPLESHEET"

if [ "$PRINT_ONLY" == "1" ]; then
    cat "$TMP_SAMPLESHEET"
    rm -f "$TMP_SAMPLESHEET"
else
    rm -f "$SAMPLESHEET"
    mv "$TMP_SAMPLESHEET" "$SAMPLESHEET"
fi

