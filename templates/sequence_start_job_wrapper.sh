#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=50G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p short

SHORT=s:f:S:T:l:p:m:
LONG=sequencer:,flowcell:,source-dir:,target-dir:,label:,pipeline-home:,mismatch:

PARSED="$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")"

if [[ $? -ne 0 ]]; then
    echo "Usage: "
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
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
        -l|--label)
            label="$2"
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

sleep $(($RANDOM % 10))
${sequencer}_start.sh --flowcell "${flowcell}" --dir "${sourceDir}/${targetDir}" -s "${sequencer}" -l "${label}" -m "${mismatch}"

