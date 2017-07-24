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
OUT_DIR="${1}/${2}/fastqc_trimmed"

mkdir -p "$OUT_DIR"
trim_galore ${3} --fastqc_args "--outdir ${OUT_DIR}" -o "${1}/${2}/"
