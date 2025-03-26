#!/bin/bash
#SBATCH --job-name=Coverage
#SBATCH --output=Logs/Coverage-%A-%a.out
#SBATCH --error=Logs/Coverage-%A-%a.err
#SBATCH --array=40
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3G    # memory per cpu-core
#SBATCH --time=12:00:00

module load mosdepth/0.3.3

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p bams_paths_27 | awk '{print $1}')
bam=$(sed -n "$SLURM_ARRAY_TASK_ID"p bams_paths_27 | awk '{print $2}')

mosdepth -n  outputs/Coverage/$sample ${bam}



