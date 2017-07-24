#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p intel

module load trim_galore
module load fastqc
trim_galore ${3} --fastqc -o ${1}/${2}/
