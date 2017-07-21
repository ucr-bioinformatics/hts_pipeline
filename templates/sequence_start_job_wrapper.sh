#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=50G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p short

SHORT=s:f:S:T:p:m:Dq:Q:
LONG=sequencer:,flowcell:,source-dir:,target-dir:,pipeline-home:,mismatch:,dev,adapter-sequence1:,adapter-sequence2:

PARSED="$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")"

if [[ $? -ne 0 ]]; then
    echo "Usage: "
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
        -q|--adapter-sequence1)
            adapterSequence1="$2"
            shift 2
            ;;
        -Q|--adapter-sequence2)
            adapterSequence2="$2"
            shift 2
            ;;
        -D|--dev)
            DEV=y
            shift
            ;;
        -s|--seq)
            sequencer="$2"
            shift 2
            ;;
        -f|--flowcell)
            flowcell="$2"
            shift 2
            ;;
        -S|--source-dir)
            sourceDir="$2"
            shift 2
            ;;
        -T|--target-dir)
            targetDir="$2"
            shift 2
            ;;
        -p|--pipeline-home)
            pipelineHome="$2"
            shift 2
            ;;
        -m|--mismatch)
            mismatch="$2"
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
    APPEND="--dev"
fi

if [[ ! -z "$adapterSequence1" ]]; then
    APPEND="${APPEND} --adapter-sequence1 ${adapterSequence1}"
    if [[ ! -z "$adapterSequence2" ]]; then
        APPEND="${APPEND} --adapter-sequence2 ${adapterSequence2}"
    fi
fi

if [[ ! -z "$APPEND" ]]; then
    echo "Appending '${APPEND}' to ${sequencer}_start.sh"
else
    echo "No additional arguments to ${sequencer}_start.sh"
fi

sleep $(($RANDOM % 10))
${sequencer}_start.sh --flowcell "${flowcell}" --dir "${sourceDir}/${targetDir}" -m "${mismatch}" ${APPEND}

