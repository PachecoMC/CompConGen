#!/bin/bash
#SBATCH -c 1
#SBATCH --mem-per-cpu 2G
#SBATCH --time=100:00:00
#SBATCH --array=40%12
#SBATCH --output=/projects/erode/apps/scripts/RefGenPaper/Logs/6.2.Het_windows_%A_%a.log
#SBATCH --job-name Het_windows

module load vcflib

scripts="/projects/erode/apps/scripts/RefGenPaper/Metadata/"
dir="/projects/erode/apps/scripts/RefGenPaper/outputs/"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $1}')
maxDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $7}')
minDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $6}') 

windows_bed="/projects/erode/apps/scripts/RefGenPaper/outputs/Het_vcf_windows/windows/${sample}_100000.bed" 


vcf_dir="/projects/erode/data/shared_data/gvcf/B10K/" # path to VCF/
vcf_path=${vcf_dir}/${sample}.vcf.gz

het_dir="${dir}/Het_vcf_windows/"

mkdir -p $het_dir

while read -r line || [[ -n "$line" ]]; do
	read -r chrom start end <<<$(echo "$line")
  	region=$(echo "$line" | awk '{print $1":"$2"-"$3}')
	
	callable=$(tabix -h $vcf_path $region | bcftools view -i "FORMAT/RGQ>10 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP|| FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" --exclude-types indels | grep -v '#' | wc -l ) 
	if [ $callable -gt 0 ]
		then
			tabix -h $vcf_path $region | bcftools view -i "FORMAT/RGQ>10 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP|| FORMAT/GQ >30 & FORMAT/DP>$minDP & FORMAT/DP<$maxDP" --exclude-types indels | vcfhetcount | tail -n 1 |  awk -v l=$callable -v chrom=$chrom -vpos=$start '{print chrom"\t"pos+50000"\t"$1"\t"l"\t"$1/l}'
		else
			echo "$region" | awk -v l=0 -v het=NA -v chrom=$chrom -v pos=$start '{print chrom"\t"pos+50000"\t"l"\t"l"\t"het}'
		fi
	callable=''
done < $windows_bed > $het_dir/${sample}_wind.het

