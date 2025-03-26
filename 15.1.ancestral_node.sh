#!/bin/bash
#SBATCH --job-name=cadd_map
#SBATCH --output=Logs/ancestral.out
#SBATCH --error=Logs/ancestral.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G    # memory per cpu-core
#SBATCH --time=8:00:00


module load hal/2.2

hal2fasta 363-avian-2020.hal birdAnc40 > outputs/Phyluce/ancestral/birdAnc40.fa
bgzip outputs/Phyluce/ancestral/birdAnc40.fa

hal2fasta 363-avian-2020.hal birdAnc273 > outputs/Phyluce/ancestral/birdAnc273.fa
bgzip outputs/Phyluce/ancestral/birdAnc273.fa

hal2fasta 363-avian-2020.hal birdAnc357 > outputs/Phyluce/ancestral/birdAnc357.fa
bgzip outputs/Phyluce/ancestral/birdAnc357.fa

cd outputs/Phyluce/ancestral

seqkit sliding -s 20 -W 200 birdAnc40.fa.gz -o fragments_birdAnc40_w200_s20.fasta.gz
seqkit sliding -s 20 -W 200 birdAnc273.fa.gz -o fragments_birdAnc273_w200_s20.fasta.gz
seqkit sliding -s 20 -W 200 birdAnc357.fa.gz -o fragments_birdAnc357_w200_s20.fasta.gz
