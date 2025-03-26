#!/bin/bash
#SBATCH -c 1
#SBATCH --mem-per-cpu 2G
#SBATCH --time=1:00:00
#SBATCH --array=40%10
#SBATCH --output=/projects/erode/apps/scripts/RefGenPaper/Logs/6.Window_%A_%a.log
#SBATCH --job-name Windows

scripts="/projects/erode/apps/scripts/RefGenPaper/Metadata/"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${scripts}Metadata_27sp.txt | awk '{print $1}')

out="/projects/erode/apps/scripts/RefGenPaper/outputs/Het_vcf_windows/windows/"

bed=${scripts}/Lists_perSp_500KbScaffolds/${sample}_500KbScaffolds.bed ;
size=100000;
slide=50000;

windowMaker -b $bed -w $size -s $slide | sortBed -i /dev/stdin | bgzip > ${out}${sample}_$size.bed.gz; tabix -p bed ${out}${sample}_$size.bed.gz
