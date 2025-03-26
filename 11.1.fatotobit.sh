#!/bin/bash
#SBATCH --job-name=phyluce
#SBATCH --output=Logs/pyluce-%A-%a.out
#SBATCH --error=Logs/phyluce-%A-%a.err
#SBATCH --array=1-40%4
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G    # memory per cpu-core
#SBATCH --time=48:00:00


conda init bash
conda activate phyluce-1.7.3

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
genome=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $2}')

mkdir $outdir/$sample
faToTwoBit ${genome} ${outdir}/${sample}/${sample}.2bit

phyluce_probe_run_multiple_lastzs_sqlite --db ${outdir}/${sample}.sqlite --output ${outdir}/genome-lastz --scaffoldlist chicken ${sample} --genome-base-path ./${outdir} --probefile ${outdir}/uce-5k-probes.fasta --cores 8
