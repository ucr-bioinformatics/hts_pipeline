#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=16G
#SBATCH --time=4:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p intel

module load fastqc
fastqc -o ${1}/${2}/fastq_report/ ${3}
