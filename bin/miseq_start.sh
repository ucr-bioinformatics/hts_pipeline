#!/bin/bash -l

#############################################
# Check for MiSeq data and execute pipeline #
#############################################

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

SHORT=f:d:m:D
LONG=flowcell:,dir:,mismatch:,dev

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
        -D|--dev)
            DEV=y
            shift
            ;;
        -f|--flowcell)
            FC_ID="$2"
            shift 2
            ;;
        -d|--dir)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -m|--mismatch)
            MISMATCH="$2"
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

SEQ="miseq"
if [[ -z "$MISMATCH" ]]; then
    MISMATCH=1
fi

# Change directory to source
cd $SOURCE_DIR

# Check for SampleSheet
complete_file=`find $SOURCE_DIR -name RTAComplete.txt`

if [ -f $complete_file ]; then
    # Determine sequencer run directory
    run_dir=`dirname $complete_file`
    dir=`dirname $run_dir`
    run_dir=`basename $run_dir`
    lockfile="${SEQ}_start.lock"
 
    # Set lock file
    lockfile-create -r 0 $SOURCE_DIR/${SEQ}_start || ( echo "Could not create $SOURCE_DIR/$lockfile" && exit 1 )

    # Set error file
    ERROR=0
    export ERROR_FILE=$SHARED_GENOMICS/$FC_ID/error.log
    mkdir -p $SHARED_GENOMICS/$FC_ID
    echo "Starting Pipeline" > $ERROR_FILE
    
    ##################
    # Pipeline Steps #
    ##################

    # Create copy of the original samplesheet from Clay and name it as SampleSheet.csv
    samplesheet_origfile=$(ls ${SHARED_GENOMICS}/Runs/$run_dir/*_FC#*.csv)
    samplesheet=$(ls ${SHARED_GENOMICS}/Runs/$run_dir/SampleSheet.csv)
    if ([ ! -z $samplesheet_origfile ]); then
        CMD="cp $samplesheet_origfile SampleSheet.csv"
    fi
    echo -e "==== Create copy of the original samplesheet from Clay STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Transfer failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Looks to change any + and . in the labeling 
    cat $samplesheet | sed '1,/Data/!d' > SampleSheet_new.csv
    cat $samplesheet | sed '1,/Data/d' |
    while IFS='' read -r line || [[ -n "$line" ]]
    do
        FIRSTHALF=$(echo $line | cut -d, -f1 | sed -e 's/\./_/g' -e 's/+/_/g' -e 's/ /_/g')
        SECONDHALF=${line:${#FIRSTHALF}}
        echo $FIRSTHALF$SECONDHALF >> SampleSheet_new.csv
    done
    mv SampleSheet_new.csv $samplesheet 

    # Transfer miseq data
    CMD="transfer_data.sh $FC_ID $SOURCE_DIR"
    echo -e "==== Transfer STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Transfer failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Checks to see if the index exists
    INDEX_EXIST=0
    cat ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv | sed '1,/Data/d' | grep -wo "index*" && INDEX_EXIST=1
    # Get barcode length
    barcode=$(tail -1 ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv | awk '{split($0,a,","); print a[6]}')
    dual_index_flag=0 
    # Create Sample Sheet for demux
    if [ $ERROR -eq 0 ]; then
        numpair=$(( $(ls ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/Basecalling_Netcopy_complete_Read*.txt | wc -l) - 1 ))
        if [ ${numpair} == 3 ]; then # Dual indexing
            dual_index_flag=1
            NUMFILES=$(( $numpair - 1 ))
            numpair=$(( $numpair - 1 ))
        else
            NUMFILES=$numpair
        fi
        MUX=1
        BASEMASK="NA"
    fi
    
    if [ $INDEX_EXIST -eq 0 ]; then
        barcode=""
    fi

   # We will demultiplex and barcode is of standard length 6 (single-end,paired-end)
    if [[ ${#barcode} -ge 6 ]]; then
       MUX=1
       BASEMASK="NA"
    fi

    #User demultiplexes and it is single end
    if [ ${numpair} == 1 ] && [ ${#barcode} == 0 ]; then
        MUX=2
        BASEMASK="Y*,Y*"
        NUMFILES=2
    fi

    #User will demultiplex and it is paired-end
    if [ ${numpair} == 2 ] && [ ${#barcode} == 0 ]; then
       MUX=2
       BASEMASK="Y*,Y*,Y*"
       NUMFILES=3
    fi 
 
    # Special case where there are dual barcodes and the user will demultiplex
    if [ $dual_index_flag -eq 1 ] && [ ${#barcode} -eq 0 ];
        BASEMASK="Y*,I*,I*,Y*"
        EXTRA_FLAG="--create-fastq-for-index-reads"
    fi



    # Demuxing step
    # They demux
    #CMD="bcl2fastq_run.sh ${FC_ID} $run_dir Y*,Y* ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv 1"
    # We demux
    CMD="bcl2fastq_run.sh ${FC_ID} $run_dir $BASEMASK ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv $MUX \"\" ${EXTRA_FLAG}"
    echo -e "==== DEMUX STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        cd $SHARED_GENOMICS/$FC_ID
        ${CMD} &> nohup.out
        if [ $? -ne 0 ]; then
            echo "ERROR:: Demuxing failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    
    # Create Sample Sheet
    if [ $dual_index_flag == 1 ]; then
        CMD="create_samplesheet_${SEQ}_i5_i7.R ${FC_ID} ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv $run_dir"
    else
        CMD="create_samplesheet_${SEQ}.R ${FC_ID} ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv $run_dir" 
    fi
    echo -e "==== SAMPLE SHEET STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: SampleSheet creation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    
    # Rename Files
    CMD="fastqs_rename.R $FC_ID ${NUMFILES} $run_dir/SampleSheet.csv $run_dir ${SEQ} $run_dir"
    echo -e "==== RENAME STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then 
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then 
            echo "ERROR: Files rename failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Check barcodes of symbolic links with an allowed mismatch of 1
    flowcell_lane="$SHARED_GENOMICS/$FC_ID/flowcell$FC_ID""_lane*.fastq.gz"
    for fastq in $(ls $flowcell_lane); do 
        file_barcode=$(echo $fastq | cut -d_ -f4 |cut -d. -f1)
        barcode=$(zcat $fastq |head -n1 | cut -d: -f10)
        echo "$barcode $file_barcode" &>> $ERROR_FILE
        index=0
        mismatch=0
        for i in $file_barcode; do
            if [ $i != ${barcode[$index]} ]; then
                mismatch=$(($mismatch+1))
            fi
        done
        if [ "$barcode" != "$file_barcode" ] && [ $mismatch -gt 1 ]; then 
            echo "FAILED" &>> $ERROR_FILE
        fi
    done

    # Generate QC report
    CMD="qc_report_generate_targets.R $FC_ID ${numpair} $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/fastq_report/ $SHARED_GENOMICS/$FC_ID/$run_dir/SampleSheet.csv $MUX"
    echo -e "==== QC STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: QC report generation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Generate second QC report
    CMD="generate_fastqc_report.sh $FC_ID"
    echo -e "==== SECOND QC STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
    	${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: FastQC report generation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Update Illumina web server URLs
	if [[ "$DEV" != "y" ]]; then
    	CMD="sequence_url_update.R $FC_ID 1 $SHARED_GENOMICS/$FC_ID"
    	echo -e "==== URL STEP ====\n${CMD}" >> "$ERROR_FILE"
    	if [ $ERROR -eq 0 ]; then
        	${CMD} &>> "$ERROR_FILE"
        	if [ $? -ne 0 ]; then
            	echo "ERROR: Illumina URL update failed" >> "$ERROR_FILE" && ERROR=1
        	fi
    	fi
	else
    	echo "URL Step skipped (in dev mode)" >> "$ERROR_FILE"
	fi
		

    # Remove lock files
    rm -f ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$lockfile
fi

# Exit
exit $ERROR

