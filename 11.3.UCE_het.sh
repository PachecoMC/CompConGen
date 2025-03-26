#!/bin/bash
#SBATCH --job-name=het
#SBATCH --output=Logs/het-%A-%a.out
#SBATCH --error=Logs/het-%A-%a.err
#SBATCH --array=1-40%4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G    # memory per cpu-core
#SBATCH --time=24:00:00


module load gsl/2.5
module load perl
module load bcftools

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce/genome-fasta"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
sample_low=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}' | sed -e 's/./\L&/')
maxDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $7}')
minDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $6}')

vcf_dir="/projects/erode/data/shared_data/gvcf/B10K/"
vcf_path=${vcf_dir}/${sample}.vcf.gz


grep 'uce' ${outdir}/${sample_low}.fasta | cut -d '|' -f 2,3,4,6 | sed 's/contig://g' | sed 's/|[a-z]*:/\t/g' | sed "s/{'-'}/reverse/g" | sed "s/{'+'}/forward/g" | sed 's/uce-/uce_/g' | sed 's/-/\t/g' > ${outdir}/${sample}.uce.list
grep 'forward' ${outdir}/${sample}.uce.list | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > ${outdir}/${sample}.uce.forward.bed
grep 'reverse' ${outdir}/${sample}.uce.list | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > ${outdir}/${sample}.uce.reverse.bed

bcftools view -R ${outdir}/${sample}.uce.forward.bed -i "FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" $vcf_path | bcftools query -i 'FORMAT/GT="0/1" & TYPE="snp"' -f '%CHROM\t%POS\t%POS\t%REF\t%ALT\n' | sort -k 1,1 -k 2,2n | bedtools map -a - -b ${outdir}/${sample}.uce.forward.bed -c 4 -o collapse > $outdir/$sample.uce.forward.gt
bcftools view -R ${outdir}/${sample}.uce.reverse.bed -i "FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" $vcf_path | bcftools query -i 'FORMAT/GT="0/1" & TYPE="snp"' -f '%CHROM\t%POS\t%POS\t%REF\t%ALT\n' | sort -k 1,1 -k 2,2n | bedtools map -a - -b ${outdir}/${sample}.uce.reverse.bed -c 4 -o collapse > $outdir/$sample.uce.reverse.gt

cut -f 2,4 $outdir/$sample.uce.forward.bed | while read -r pos uce; do grep -E "${uce},|${uce}$" $outdir/$sample.uce.forward.gt | awk -v pos="$pos" -v uce="$uce" '{print $1 "\t" $2 "\t" $3 "\t" uce "\t" $2-pos "\t" $4 "\t" $5}'; done > $outdir/$sample.uce.forward.mapped.gt
cut -f 3,4 $outdir/$sample.uce.reverse.bed | while read -r pos uce; do grep -E "${uce},|${uce}$" $outdir/$sample.uce.reverse.gt | awk -v pos="$pos" -v uce="$uce" '{print $1 "\t" $2 "\t" $3 "\t" uce "\t" pos-$2+1 "\t" $4 "\t" $5}'; done > $outdir/$sample.uce.reverse.uncompliment.mapped.gt
awk '{
	if ($6=="T") sub("T","A",$6);
	else if ($6=="A") sub("A","T",$6);
	else if ($6=="C") sub("C","G",$6);
	else if ($6=="G") sub("G","C",$6);
	print
}' $outdir/$sample.uce.reverse.uncompliment.mapped.gt | awk '{
	if ($7=="T") sub("T","A",$7);
	else if ($7=="A") sub("A","T",$7);
	else if ($7=="C") sub("C","G",$7);
	else if ($7=="G") sub("G","C",$7);
	print
}' | sed 's/ /\t/g' > $outdir/$sample.uce.reverse.mapped.gt
