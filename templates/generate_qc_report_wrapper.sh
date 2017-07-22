#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=4G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p short 

FILES="$4"

echo "Generating QC report for ${FILES}"

module load fastqc
if [ "${3}" == "0" ]; then
    fastqc -t 10 -o ${1}/${2}/fastq_report/ ${FILES}
else
    fastqc -o ${1}/${2}/fastq_report/fastq_report_lane${3}/ ${FILES}
fi
