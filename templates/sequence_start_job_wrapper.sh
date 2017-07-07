#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=50G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p short

SHORT=dfo:v
LONG=debug,force,output:,verbose

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"

while true; do
    case "$1" in
        -s|--seq)
            sequencer=y
            shift
            ;;
        -f|--flowcell)
            flowcell=y
            shift
            ;;
        -sd|--source-dir)
            sourceDir=y
            shift
            ;;
        -td|--target-dir)
            targetDir=y
            shift
            ;;
        -l|--label)
            label=y
            shift
            ;;
        -p|--pipeline-home)
            pipelineHome=y
            shift
            ;;
        -m|--mismatch)
            mismatch=y
            shift
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
${sequencer}_start.sh -f ${flowcell} -sd ${sourceDir}/${targetDir} -s ${sequencer} -l ${label} -m ${mismatch}

