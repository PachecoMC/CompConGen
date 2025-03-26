#!/bin/bash
#SBATCH --job-name=TE_RM_AS24
#SBATCH --output=AS24_TE_RM.out
#SBATCH --error=AS24_TE_RM.err
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=16G    # memory per cpu-core
#SBATCH --time=96:00:00

module load repeatmasker/4.1.5

RepeatMasker AS24_nuc.fasta -lib ../all_combined_curated.fasta -pa 20
