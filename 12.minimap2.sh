#!/bin/bash
#SBATCH --job-name=minimap
#SBATCH --error=Logs/minimap-%A-%a.err
#SBATCH --array=5-40%4
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=12G    # memory per cpu-core
#SBATCH --time=14:00:00

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/minimap"
chicken="/projects/erode/data/reference_genomes/Chicken6a/Gallus_gallus.GRCg6a.dna.toplevel.fa"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
ref=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $2}')

minimap2 -t 4 -f 0.02 $chicken $ref > $outdir/$sample.paf
