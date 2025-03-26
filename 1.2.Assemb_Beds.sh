#!/bin/bash
#SBATCH --job-name=AssembIndxBeds
#SBATCH --output=Logs/AssembIndxBeds-%A-%a.out
#SBATCH --error=Logs/AssembIndxBeds-%A-%a.err
#SBATCH --array=28-40
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G    # memory per cpu-core
#SBATCH --time=24:00:00

module load pyfaidx/

# New species
meta="/projects/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt"
Sp=$(sed -n ${SLURM_ARRAY_TASK_ID}p $meta  | awk '{print $1}')
assy=$(sed -n ${SLURM_ARRAY_TASK_ID}p $meta  | awk '{print $2}')


pathBeds="/projects/erode/data/reference_genomes/B10K_replacements/bed_files"


faidx $assy -i bed > $pathBeds/$Sp.bed




