#!/bin/bash
#SBATCH --job-name=psmc
#SBATCH --output=Logs/psmc-%A-%a.out
#SBATCH --error=Logs/psmc-%A-%a.err
#SBATCH --array=3,4,8,11,12,15,17,18,19,20,21,24,26,36%4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G    # memory per cpu-core
#SBATCH --time=20:00:00

module load psmc/0.6.5
module load samtools/1.19.2
module load gnuplot/5.4.3

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/PSMC"
psmc_meta="Metadata/psmc_data.txt"

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $1}')
bam=$(sed -n "$SLURM_ARRAY_TASK_ID"p $meta | awk '{print $3}')

sample_psmc=$(sed -n "$SLURM_ARRAY_TASK_ID"p $psmc_meta | awk '{print $1}')
generation=$(sed -n "$SLURM_ARRAY_TASK_ID"p $psmc_meta | awk '{print $2}')
mutation=$(sed -n "$SLURM_ARRAY_TASK_ID"p $psmc_meta | awk '{print $3}')

samtools consensus -f fastq -A --min-MQ 30 --min-BQ 30 -d 10 $bam -o $outdir/${sample}.psmc.fq
gzip $outdir/${sample}.psmc.fq
fq2psmcfa $outdir/${sample}.psmc.fq.gz > $outdir/${sample}.psmcfa
psmc -N40 -t5 -r5 -p 4+30*2+4+6+10 -o $outdir/${sample}.psmc $outdir/${sample}.psmcfa
psmc -N30 -t5 -r5 -p "1+1+1+1+30*2+4+6+10" -o $outdir/${sample}_v2.psmc $outdir/v1/${sample}.psmcfa
psmc_plot.pl -x5000 -X1000000 -g$generation -u$mutation $outdir/${sample_psmc}_v2 $outdir/${sample_psmc}_v2.psmc
