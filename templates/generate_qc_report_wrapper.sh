#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=16G
#SBATCH --time=4:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p intel

module load fastqc
if [ "${4}" == "0" ]; then
    fastqc -o ${1}/${2}/fastq_report/ ${3}
else
    fastqc -o ${1}/${2}/fastq_report/fastq_report_lane${4}/ ${3}
fi
