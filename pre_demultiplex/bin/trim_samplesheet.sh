#!/bin/bash -l

if [ $# -lt 1 ]; then
    echo "Usage: trim_samplesheet.sh <SampleSheet> [dualBarcodes = 0] [printOnly = 0]"
    exit 1
fi

SAMPLESHEET="$1"
TMP_SAMPLESHEET="$1.tmp"
DUAL_BARCODES="${2:-0}"
PRINT_ONLY="${3:-0}"

# Handle the case of $SAMPLESHEET.tmp already existing by appending another .tmp
while [ -f "$TMP_SAMPLESHEET" ]; do
    TMP_SAMPLESHEET="${TMP_SAMPLESHEET}.tmp"
done

if [ $DUAL_BARCODES -eq 1 ]; then
    START_COL=5
    END_COL=8
else
    START_COL=6
    END_COL=6
fi

awk -F',' -v startCol="$START_COL" -v endCol="$END_COL" '
BEGIN {
    OFS = FS;
}

{if(process != 1) {
    print $0
}}

/Sample_ID/ {
    process = 1;
    next;
}

{if(process == 1) {
    for(i = startCol; i <= endCol; i++)
        $i = ""
    print $0;
    exit
}}' "$SAMPLESHEET" > "$TMP_SAMPLESHEET"

if [ "$PRINT_ONLY" == "1" ]; then
    cat "$TMP_SAMPLESHEET"
    rm -f "$TMP_SAMPLESHEET"
else
    rm -f "$SAMPLESHEET"
    mv "$TMP_SAMPLESHEET" "$SAMPLESHEET"
fi

