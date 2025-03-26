#!/bin/bash
#SBATCH --job-name=CADD
#SBATCH --output=Logs/CADD.out
#SBATCH --error=Logs/CADD.err
#SBATCH --array=1-33%4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G    # memory per cpu-core
#SBATCH --time=18:00:00


meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce/cadd_map"


cd $outdir
bedtools intersect -b ../genome-fasta/chicken.uce.list -a ~/test/chicken/chCADD-scores/split_CADD/bed_files/chCADD_chr${SLURM_ARRAY_TASK_ID}_1_based.bed > chr${SLURM_ARRAY_TASK_ID}_UCE_CADD.bed
