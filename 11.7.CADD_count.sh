#!/bin/bash
#SBATCH --job-name=het
#SBATCH --output=Logs/het-%A-%a.out
#SBATCH --error=Logs/het-%A-%a.err
#SBATCH --array=1-40%4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G    # memory per cpu-core
#SBATCH --time=24:00:00


meta="Metadata/Metadata_27sp.txt"
uce_dir="outputs/Phyluce/genome-fasta"
minimap_dir="outputs/minimap"
cadd_dir="outputs/Phyluce/cadd_map"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')

cp $cadd_dir/$sample.hom.cadd.bed $cadd_dir/$sample.auto.hom.cadd.bed
cp $cadd_dir/$sample.het.cadd.bed $cadd_dir/$sample.auto.het.cadd.bed

grep $sample $minimap_dir/chromosome_info_combined.list | cut -f 3 | while read chr
do
	grep $chr $uce_dir/$sample.uce.list | cut -f 4 | sed "s/_/-/g" | while read line
	do
		sed -i "/${line}_/d" $cadd_dir/$sample.auto.het.cadd.bed
		sed -i "/${line}_/d" $cadd_dir/$sample.auto.hom.cadd.bed
	done
done

awk -v species="$sample" '{if ($7>=20) (n+=1); if ($7>=13 && $7<20) (m+=1); if ($7>=10 && $7<13) (l+=1); if ($7>=6 && $7<10) (k+=1); if ($7>=3 && $7<6) (g+=1)}END{print species " " n " " m " " l " " k " " g}' $cadd_dir/$sample.auto.het.cadd.bed >> $cadd_dir/auto_het.count

awk -v species="$sample" '{if ($7>=20) (n+=1); if ($7>=13 && $7<20) (m+=1); if ($7>=10 && $7<13) (l+=1); if ($7>=6 && $7<10) (k+=1); if ($7>=3 && $7<6) (g+=1)}END{print species " " n " " m " " l " " k " " g}' $cadd_dir/$sample.auto.hom.cadd.bed >> $cadd_dir/auto_hom.count
