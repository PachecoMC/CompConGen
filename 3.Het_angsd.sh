#!/bin/bash
#SBATCH --job-name=Het_angsd
#SBATCH --output=Logs/Het_angsd-%A-%a.out
#SBATCH --error=Logs/Het_angsd-%A-%a.err
#SBATCH --array=40
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8G    # memory per cpu-core
#SBATCH --time=72:00:00


module load angsd/0.940
module load winsfs/0.7.0

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Het_angsd"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
ref=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $2}')
bam=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $3}')
scaffolds=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $4}')
minDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $6}')
maxDP=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $7}')

# Overall (scaffolds > 500Kb) 

angsd  -i $bam -ref $ref -rf $scaffolds -anc $ref -out ${outdir}/${sample}_forhet -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -C 50 -baq 0 -minMapQ 30 -minQ 20 -setMinDepth $minDP -setMaxDepth $maxDP -doCounts 1 -nThreads 10 -GL 2 -doSaf 1
realSFS ${outdir}/${sample}_forhet.saf.idx -fold 1 -P 10 > ${outdir}/GenomeWide/${sample}_het.ml

# Per scaffold (> 500Kb)

while read scaff
do
  scaffname=$(cut -d: -f1 <<< $scaff)
	angsd  -i $bam -ref $ref -r $scaff -anc $ref -out ${outdir}/${sample}_${scaffname}_forhet -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -C 50 -baq 0 -minMapQ 30 -minQ 20 -setMinDepth $minDP -setMaxDepth $maxDP -doCounts 1 -nThreads 10 -GL 2 -doSaf 1
	realSFS ${outdir}/${sample}_${scaffname}_forhet.saf.idx -fold 1 > ${outdir}/PerScaffold/${sample}_${scaffname}_het.ml
done < $scaffolds