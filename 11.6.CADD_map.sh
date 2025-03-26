#!/bin/bash
#SBATCH --job-name=cadd_map
#SBATCH --output=Logs/CADD_map.out
#SBATCH --error=Logs/CADD_map.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G    # memory per cpu-core
#SBATCH --time=8:00:00


meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce/cadd_map"

cd $outdir
for i in {1..33}; do cat chr${i}_UCE_CADD.bed; done > chicken_CADD.uce.bed

cut -f 1 $meta | while read line;
do
	bedtools subtract -a $line.hom.bed -b $line.het.bed | 
		bedtools intersect -a chicken_CADD.uce.bed -b - -wb | 
		awk '{if ($5==$11) {print $1 "\t" $2 "\t" $3 "\t" $12 "\t" $10 "\t" $11 "\t" $6}}' > $line.hom.cadd.bed
	awk '{if ($4!=$8 && $4!=$7) ($5="N"); if ($4==$5) ($5=$8); print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' $line.het.bed |
		bedtools intersect -a chicken_CADD.uce.bed -b - -wb |
                awk '{if ($5==$11) {print $1 "\t" $2 "\t" $3 "\t" $12 "\t" $10 "\t" $11 "\t" $6}}' > $line.het.cadd.bed
done

