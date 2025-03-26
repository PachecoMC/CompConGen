#!/bin/bash
#SBATCH --job-name=AssembIndxBeds
#SBATCH --output=Logs/AssembIndxBeds-%A-%a.out
#SBATCH --error=Logs/AssembIndxBeds-%A-%a.err
#SBATCH --array=1-24
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G    # memory per cpu-core
#SBATCH --time=24:00:00


module load bwa/0.7.17
module load pyfaidx/
assy=$(sed -n ${SLURM_ARRAY_TASK_ID}p assemb_paths)

bwa index $assy

spName=$(grep -oP '(?<=B10K_replacements/).*?(?=/data)' <<< "$assy")
pathBeds="/projects/erode/data/reference_genomes/B10K_replacements/bed_files"

faidx $assy -i bed > $pathBeds/$spName.bed
