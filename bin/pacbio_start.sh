#!/usr/bin/env bash -l

# Set global vars
source "$HTS_PIPELINE_HOME/env_profile.sh"

SHORT=D:d:f:
LONG=dev,dir:,flowcell:

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"

pacbioPrefix="pacbio" # Prefix used for before folder name in $GENOMICS_SHARED

while true; do
    case "$1" in
        -f|--flowcell) # The folder name for PacBio - named flowcell to be backwards compatible
            folderName="$2"
            FC_ID="$folderName"
            shift 2
            ;;
        -D|--dev)
            DEV=y
            shift
            ;;
        -d|--dir)
            sourceDir="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

cd "$sourceDir"

outputDir="$SHARED_GENOMICS/$folderName"
analysisDir="$SHARED_GENOMICS/RunAnalysis/${pacbioPrefix}${folderName}"
ERROR=0
export ERROR_FILE="$SHARED_GENOMICS/$folderName/error.log"

mkdir -p "$SHARED_GENOMICS/$folderName"
echo "Started Pipeline" > "$ERROR_FILE"

#========================
# Step 1: Check checksums
#========================
CMD="shasum -c '$sourceDir/checksums.sha1'"
echo -e "==== Step 1: Check Checksums ====\n${CMD}" >> "$ERROR_FILE"
if [ $ERROR -eq 0 ]; then
    if [ ${CMD} &>> "$ERROR_FILE" -ne 0 ]; then
        echo "ERROR: Checksum check failed"
    fi
fi

#===================================
# Step 2: Move folder to RunAnalysis
#===================================
CMD="mv ${sourceDir} $analysisDir"
echo -e "==== Step 2: Move folder to RunAnalysis ====\n${CMD}" >> "$ERROR_FILE"
if [ $ERROR -eq 0 ]; then
    if [ ${CMD} &>> "$ERROR_FILE" -ne 0 ]; then
        echo "ERROR: Moving folder failed"
    fi
fi
chmod -R u-w "${analysisDir}"

#==========================
# Step 3: Create hard links
#==========================
CMD="cp -l ${analysisDir} ${outputDir}"
echo -e "==== Step 3: Create hard links ====\n${CMD}" >> "$ERROR_FILE"
if [ $ERROR -eq 0 ]; then
    if [ ${CMD} &>> "$ERROR_FILE" -ne 0 ]; then
        echo "ERROR: Creating hard links"
    fi
fi


#==========================
# Step 4: Create QC reports
#==========================
