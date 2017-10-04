#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32G
#SBATCH --time=24:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p intel

echo "Generating R QC report with args: $@"

$HTS_PIPELINE_HOME/bin/qc_report_generate_targets.R "$@"
