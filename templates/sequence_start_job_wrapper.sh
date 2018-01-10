#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=5G
#SBATCH --time=4:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p batch

SHORT=s:f:S:T:p:m:DtP:b:
LONG=sequencer:,flowcell:,source-dir:,target-dir:,pipeline-home:,mismatch:,dev,trim-galore,password-protect:,base-mask:

PARSED="$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")"

if [[ $? -ne 0 ]]; then
    echo "Usage: "
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
        -b|--base-mask)
            baseMask="$2"
            shift 2
            ;;
        -P|--password-protect)
            passwordProtect="$2"
            shift 2
            ;;
        -t|--trim-galore)
            trimGalore=y
            shift
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

if [[ "$trimGalore" == "y" ]]; then
    APPEND="${APPEND} --trim-galore"
fi

if [[ ! -z "$mismatch" ]]; then
    APPEND="${APPEND} -m $mismatch"
fi

if [[ ! -z "$baseMask" ]]; then
    APPEND="${APPEND} -b $baseMask"
fi

sleep $(($RANDOM % 10))
${sequencer}_start.sh --flowcell "${flowcell}" --dir "${sourceDir}/${targetDir}" --password-protect ${passwordProtect:-0} ${APPEND:-}

