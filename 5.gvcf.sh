#!/bin/bash
#SBATCH --job-name=gvcf
#SBATCH --output=Logs/gvcf-%A-%a.out
#SBATCH --error=Logs/gvcf-%A-%a.err
#SBATCH --array=40%1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=16G    # memory per cpu-core
#SBATCH --time=80:00:00


meta="Metadata/Metadata_27sp.txt"
outdir="/projects/erode/data/shared_data/gvcf/B10K"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
ref=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $2}')
bam=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $3}')
ref_name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $2}' | sed "s/.fasta//g")

module load python/3.9.9
module load openjdk/17.0.8
module load gatk/4.4.0.0

gatk CreateSequenceDictionary -R $ref -O ${ref_name}.dict 
gatk --java-options "-Xmx50g -Xms16g -XX:ParallelGCThreads=8" HaplotypeCaller -R $ref -ERC BP_RESOLUTION -I $bam -O $outdir/${sample}.g.vcf.gz --max-num-haplotypes-in-population 4 --max-assembly-region-size 100 --min-dangling-branch-length 16
gatk --java-options "-Xmx50g -Xms16g -XX:ParallelGCThreads=8" GenotypeGVCFs -R $ref -V $outdir/${sample}.g.vcf.gz -O $outdir/${sample}.vcf.gz --include-non-variant-sites 
