#!/bin/bash
#SBATCH -c 16
#SBATCH --mem-per-cpu 2G
#SBATCH --time=16:00:00
#SBATCH --array=23,24
#SBATCH --output=Logs/Comp_Rohan_%A_%a.log
#SBATCH --job-name Rohan


module load jdk/1.8.0_291 picard/2.27.5
module load rohan

picard=/opt/software/picard/2.27.5/picard.jar

dir=/projects/erode/apps/scripts/RefGenPaper/outputs/Rohan_Comp


sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p /projects/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt  | awk '{print $1}')
bam=$(sed -n "$SLURM_ARRAY_TASK_ID"p  /projects/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt | awk '{print $3}')
ref=$(sed -n "$SLURM_ARRAY_TASK_ID"p  /projects/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt | awk '{print $2}')
scaffolds=/projects/erode/apps/scripts/RefGenPaper/Metadata/Lists_perSp_500KbScaffolds/${sample}_500KbScaffolds_5Mb.list 

rohan -t 16 --size 100000 --rohmu 5e-4 --auto $scaffolds -o ${dir}/5e4/${sample}_5e4_100kb $ref ${bam}

