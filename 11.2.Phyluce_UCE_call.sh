#!/bin/bash
#SBATCH --job-name=phyluce
#SBATCH --output=Logs/pyluce_call.out
#SBATCH --error=Logs/phyluce_call.err
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G    # memory per cpu-core
#SBATCH --time=24:00:00


conda init bash
conda activate phyluce-1.7.3

meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce"

samples=$(cut -f 1 $meta | tr '\n' ' ')

phyluce_probe_run_multiple_lastzs_sqlite --db ${outdir}/all.sqlite --output ${outdir}/genome-lastz --scaffoldlist chicken ${samples} --genome-base-path ./${outdir} --probefile ${outdir}/uce-5k-probes.fasta --cores 8

phyluce_probe_slice_sequence_from_genomes \
    --lastz ${outdir}/genome-lastz \
    --conf ${outdir}/genomes.conf \
    --name-pattern "uce-5k-probes.fasta_v_{}.lastz.clean" \
    --output ${outdir}/genome-fasta

phyluce_assembly_match_contigs_to_probes \
    --contigs ${outdir}/contigs \
    --probes ${outdir}/uce-5k-probes.fasta \
    --output ${outdir}/uce-search-results

phyluce_assembly_get_match_counts \
    --locus-db ${outdir}/uce-search-results/probe.matches.sqlite \
    --taxon-list-config ${outdir}/taxon-set.conf \
    --taxon-group 'all' \
    --incomplete-matrix \
    --output ${outdir}/taxon-sets/all/all-taxa-incomplete.conf

phyluce_assembly_get_fastas_from_match_counts \
    --contigs ${outdir}/contigs \
    --locus-db ${outdir}/uce-search-results/probe.matches.sqlite \
    --match-count-output ${outdir}/taxon-sets/all/all-taxa-incomplete.conf \
    --output ${outdir}/taxon-sets/all/all-taxa-incomplete.fasta \
    --incomplete-matrix ${outdir}/taxon-sets/all/all-taxa-incomplete.incomplete \
    --log-path ${outdir}/taxon-sets/all/

cd ${outdir}/taxon-sets/no_flank
phyluce_align_seqcap_align \
    --input all-taxa-incomplete.fasta \
    --output mafft-nexus-internal-trimmed \
    --taxa 41 \
    --aligner mafft \
    --cores 8 \
    --incomplete-matrix \
    --output-format fasta \
    --no-trim \
    --log-path ./

phyluce_align_get_gblocks_trimmed_alignments_from_untrimmed \
    --alignments mafft-nexus-internal-trimmed \
    --output mafft-nexus-internal-trimmed-gblocks \
    --cores 8 \
    --log ./

phyluce_align_remove_locus_name_from_files \
    --alignments mafft-nexus-internal-trimmed-gblocks \
    --output mafft-nexus-internal-trimmed-gblocks-clean \
    --cores 8 \
    --log-path ./


