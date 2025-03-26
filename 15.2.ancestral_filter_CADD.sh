#!/bin/bash
#SBATCH --job-name=cadd_map
#SBATCH --output=Logs/ancestral_filter.out
#SBATCH --error=Logs/ancestral_filter.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G    # memory per cpu-core
#SBATCH --time=8:00:00


module load mosdepth
module load perl
module load gsl/2.5
module load bcftools

cd outputs/Phyluce/ancestral

samtools index birdAnc273_chicken_bwa.bam
cat ../genome-fasta/chicken.uce.*.bed | sort -k1,1n -k2,2n | samtools view -L - -b birdAnc273_chicken_bwa.bam | samtools sort > birdAnc273_chicken_bwa_uce.bam
samtools index birdAnc273_chicken_bwa_uce.bam
mosdepth birdAnc273_chicken_bwa_uce birdAnc273_chicken_bwa_uce.bam
zcat birdAnc273_chicken_bwa_uce.per-base.bed.gz | awk '{if ($4>1) print}' | bedtools merge > birdAnc273_chicken_bwa_uce_mapped.bed
bcftools mpileup -f ~/erode/data/reference_genomes/Chicken6a/Gallus_gallus.GRCg6a.dna.toplevel.fa birdAnc273_chicken_bwa_uce.bam | bcftools call --ploidy 1 -vcO v -V indels > birdAnc273_chicken_bwa_uce.vcf
bcftools query -f "%CHROM\t%POS0\t%POS\n" birdAnc273_chicken_bwa_uce.vcf > birdAnc273_chicken_bwa_uce.vcf.bed
bedtools intersect -b birdAnc273_chicken_bwa_uce_mapped.bed -a ../cadd_map/Oceanites_oceanicus.auto.hom.cadd.bed -u | bedtools intersect -a - -b birdAnc273_chicken_bwa_uce.vcf.bed -v > Oceanites_oceanicus.auto.hom.filter.bed

samtools index birdAnc40_chicken_bwa.bam
cat ../genome-fasta/chicken.uce.*.bed | sort -k1,1n -k2,2n | samtools view -L - -b birdAnc40_chicken_bwa.bam | samtools sort > birdAnc40_chicken_bwa_uce.bam
samtools index birdAnc40_chicken_bwa_uce.bam
mosdepth birdAnc40_chicken_bwa_uce birdAnc40_chicken_bwa_uce.bam
zcat birdAnc40_chicken_bwa_uce.per-base.bed.gz | awk '{if ($4>1) print}' | bedtools merge > birdAnc40_chicken_bwa_uce_mapped.bed
bcftools mpileup -f ~/erode/data/reference_genomes/Chicken6a/Gallus_gallus.GRCg6a.dna.toplevel.fa birdAnc40_chicken_bwa_uce.bam | bcftools call --ploidy 1 -vcO v -V indels > birdAnc40_chicken_bwa_uce.vcf
bcftools query -f "%CHROM\t%POS0\t%POS\n" birdAnc40_chicken_bwa_uce.vcf > birdAnc40_chicken_bwa_uce.vcf.bed
bedtools intersect -b birdAnc40_chicken_bwa_uce_mapped.bed -a ../cadd_map/Halcyon_senegalensis.auto.hom.cadd.bed -u | bedtools intersect -a - -b birdAnc40_chicken_bwa_uce.vcf.bed -v > Halcyon_senegalensis.auto.hom.filter.bed

samtools index birdAnc357_chicken_bwa.bam
cat ../genome-fasta/chicken.uce.*.bed | sort -k1,1n -k2,2n | samtools view -L - -b birdAnc357_chicken_bwa.bam | samtools sort > birdAnc357_chicken_bwa_uce.bam
samtools index birdAnc357_chicken_bwa_uce.bam
mosdepth birdAnc357_chicken_bwa_uce birdAnc357_chicken_bwa_uce.bam
zcat birdAnc357_chicken_bwa_uce.per-base.bed.gz | awk '{if ($4>1) print}' | bedtools merge > birdAnc357_chicken_bwa_uce_mapped.bed
bcftools mpileup -f ~/erode/data/reference_genomes/Chicken6a/Gallus_gallus.GRCg6a.dna.toplevel.fa birdAnc357_chicken_bwa_uce.bam | bcftools call --ploidy 1 -vcO v -V indels > birdAnc357_chicken_bwa_uce.vcf
bcftools query -f "%CHROM\t%POS0\t%POS\n" birdAnc357_chicken_bwa_uce.vcf > birdAnc357_chicken_bwa_uce.vcf.bed
bedtools intersect -b birdAnc357_chicken_bwa_uce_mapped.bed -a ../cadd_map/Rhea_americana.auto.hom.cadd.bed -u | bedtools intersect -a - -b birdAnc357_chicken_bwa_uce.vcf.bed -v > Rhea_americana.auto.hom.filter.bed
