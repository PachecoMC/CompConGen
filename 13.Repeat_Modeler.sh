#!/bin/bash
#SBATCH --job-name=TE_01_AS24
#SBATCH --output=AS24_TEg.out
#SBATCH --error=AS24_TE.err
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=16G    # memory per cpu-core
#SBATCH --time=96:00:00


module load repeatmodeler/2.0.4

BuildDatabase -name AS24 *_nuc.fasta

RepeatModeler -database AS24 -threads 20 -LTRStruct
