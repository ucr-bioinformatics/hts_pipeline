#!/bin/bash -l

########################
# Start HTS Pipeline #
########################

echo "started running"

SHORT=m:Dq:Q:n
LONG=mismatch:,dev,adapter-sequence1:,adapter-sequence2:,no-mail

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 2
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

while true; do
    case "$1" in
        -n|--no-mail)
            noMail=y
            shift
            ;;
        -m|--mismatch)
            mismatch="$2"
            shift 2
            ;;
        -D|--dev)
            DEV=y
            shift
            ;;
        -q|--adapter-sequence1)
            adapterSequence1="$2"
            shift 2
            ;;
        -Q|--adapter-sequence2)
            adapterSequence2="$2"
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

if [[ "$DEV" == "y" ]]; then
    echo "Running in development mode"
fi

if [[ ! -z "$adapterSequence1" ]]; then
    echo "Using adapterSequence1: ${adapterSequence1}"
    if [[ ! -z "$adapterSequence2" ]]; then
        echo "Using adapterSequence2: ${adapterSequence2}"
    fi
fi

# Set global vars
source "$HTS_PIPELINE_HOME/env_profile.sh"
source "$HTS_PIPELINE_HOME/bin/load_hts_passwords.sh"

# Change directory to source
SOURCE_DIR="${SHARED_GENOMICS}/Runs"
cd "$SOURCE_DIR" || echo "Unable to change directory"

# Get list of Run directories
dir_list=$(find . -maxdepth 1 -type d)

# Iterate over each Run directory
for dir in $dir_list; do
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Find sample sheet
        complete_file=$(find "$dir" -name RTAComplete.txt)
        samplesheet_file=$(find "$dir" -maxdepth 1 -name '*_FC#*.csv')
        samplesheet_db="SampleSheet_DB.csv"
        samplesheet=$(find "$dir" -maxdepth 1 -name SampleSheet.csv)
        
        if [ ! -z "$complete_file" ] && ([ ! -z "$samplesheet_file" ] || [ ! -z "$samplesheet" ] || [ ! -z "$samplesheet_db" ]); then
            # Determine Sequencer type
            str=$(echo "$dir" | cut -d_ -f2)
            case $str in
            "SN279")
                SEQ="hiseq"
            ;;
            "NB501124")
                SEQ="nextseq"
            ;;
            "NB501891")
                SEQ="nextseq"
            ;;
            "M02457")
                SEQ="miseq"
            ;;
            *)
                SEQ="default"
            ;;
            esac

            # Pull chars from dir name
            str=$(echo "$dir" | grep -oP "[A-Z0-9]+$")
            if [[ ${#str} -eq 10 ]]; then
                label=${str:1:10}
            else
                label=$str
            fi
            
            # Determine flowcell ID
            QUERY="SELECT flowcell_id FROM flowcell_list WHERE label=\"$label\";"
            FC_ID=$(mysql -hillumina.int.bioinfo.ucr.edu -Dprojects -u$DB_USERNAME -p$DB_PASSWORD -N -s -e "${QUERY}")

            
            if [[ -z "$noMail" ]]; then
                # Send email notification
                echo "Sending Mail"
                /usr/sbin/sendmail -vt << EOF
To: ${NOTIFY_EMAIL}
From: no-reply@biocluster.ucr.edu
Subject: HTS Pipeline: Flowcell ${FC_ID}: Started

Flowcell ${FC_ID} has come in and is being processed.
Thanks
EOF
            fi
            if [[ ! -z "$DEV" ]]; then
                APPEND="--dev"
            fi

            if [[ ! -z "$adapterSequence1" ]]; then
                APPEND="${APPEND} --adapter-sequence1 ${adapterSequence1}"
                if [[ ! -z "$adapterSequence2" ]]; then
                    APPEND="${APPEND} --adapter-sequence2 ${adapterSequence2}"
                fi
            fi

            echo "Processing ${FC_ID} from ${SOURCE_DIR}/$dir" >> "${HTS_PIPELINE_HOME}/log/${SEQ}_pipeline.log"
            #echo ${SEQ}_start.sh ${FC_ID} ${SOURCE_DIR}/$dir ${SEQ} ${label}| qsub -l nodes=1:ppn=32,mem=50gb,walltime=20:00:00 -j oe -o ${HTS_PIPELINE_HOME}/log/${SEQ}_start.log -m bea -M ${NOTIFY_EMAIL}
            module load slurm
            sbatch sequence_start_job_wrapper.sh -s "${SEQ}" -f "${FC_ID}" -S "${SOURCE_DIR}" -T "$dir" -p "${HTS_PIPELINE_HOME}" -m "${mismatch:-1}" ${APPEND}

        fi
    fi
done

#########################
# Start HiSeq Pipeline? #
#########################

exit $?
