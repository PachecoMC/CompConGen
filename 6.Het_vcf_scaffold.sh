#!/bin/bash
#SBATCH -c 1
#SBATCH --mem-per-cpu 2G
#SBATCH --time=12:00:00
#SBATCH --array=40%10
#SBATCH --output=/projects/erode/apps/scripts/RefGenPaper/Logs/6.Het_scaffold_%A_%a.log
#SBATCH --job-name Het_scaffold
module load vcflib

# Script to estimate heterozygosity from a VCF file per scaffold (it generates one file per sample and per scaffold).

scripts="/projects/erode/apps/scripts/RefGenPaper/Metadata/"
dir="/projects/erode/apps/scripts/RefGenPaper/outputs/"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $1}')
scaffolds=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $4}') # create this file to have in the second column the path to bed file of scaffolds with format: scaffold start end
maxDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $7}') 
minDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $6}') 

vcf_dir="/projects/erode/data/shared_data/gvcf/B10K/" # path to VCF/
vcf_path=${vcf_dir}/${sample}.vcf.gz 

het_dir="${dir}/Het_vcf_scaffolds/"

while read region; 
do
        chrom=$(echo $region | cut -d":" -f1)
	callable=$(tabix -h $vcf_path $region |  bcftools view -i "FORMAT/RGQ>10 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP|| FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" --exclude-types indels | grep -v '#' | wc -l ) 
	if [ $callable -gt 0 ]
		then
			tabix -h $vcf_path $region |  bcftools view -i "FORMAT/RGQ>10 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP|| FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" --exclude-types indels | vcfhetcount | tail -n 1 |  awk -v l=$callable -v chrom=$chrom '{print chrom"\t"$1"\t"l"\t"$1/l}' > ${het_dir}/${sample}_${chrom}_new.het
		else
			echo "$region" | awk -v l=0 -v het=NA -v chrom=$chrom '{print chrom"\t"0"\t"l"\t"het}' > ${het_dir}/${sample}_${chrom}_new.het
		fi
	callable=''
done < $scaffolds

