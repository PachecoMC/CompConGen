#!/bin/bash
#SBATCH --job-name=liftover
#SBATCH --output=Logs/liftover.out
#SBATCH --error=Logs/liftover.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G    # memory per cpu-core
#SBATCH --time=8:00:00


meta="Metadata/Metadata_27sp.txt"
outdir="outputs/Phyluce"

samples=$(cut -f 1 $meta | tr '\n' ' ')

cd $outdir/taxon-sets/all/het

cut -f 1 ~/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt | while read line; do awk -v species="$line" '{print $0 "\t" species}' ~/erode/apps/scripts/RefGenPaper/outputs/Phyluce/genome-fasta/$line.uce.forward.mapped.gt; awk -v species="$line" '{print $0 "\t" species}' ~/erode/apps/scripts/RefGenPaper/outputs/Phyluce/genome-fasta/$line.uce.reverse.mapped.gt; done > het.mapped.gt

cat ../all-taxa-incomplete.conf | grep "uce" | while read line; do awk -v uce="$line" '{if ($4==uce) {print $4 "\t" $5 "\t" $6 "\t" $7 "\t" uce "_" $8}}' het.mapped.gt | sort -k5,5 -k2,2n > $line.het.gt ; done

cat ../all-taxa-incomplete.conf | grep "uce" | while read line
do
	python ~/erode/apps/scripts/RefGenPaper/UCE_het.py -i ../mafft-nexus-internal-trimmed/$line.fasta -p $line.het.gt -r ${line}_chicken -o $line.het.list
done

cd ../alt

cat ../all-taxa-incomplete.conf | grep "uce" | while read line
do
	python ~/erode/apps/scripts/RefGenPaper/UCE.py -i ../mafft-nexus-internal-trimmed/$line.fasta -r ${line}_chicken -o $line.hom.list
done

cd /projects/erode/apps/scripts/RefGenPaper/outputs/Phyluce/genome-fasta

cut -f 4 chicken.uce.forward.bed | while read line
do
	grep "${line}$" chicken.uce.forward.bed | while read chr begin end uce
	do
		awk -v "chr=$chr" -v "begin=$begin" -v "uce=$uce" '{print chr "\t" begin+$1 "\t" begin+$1 "\t" toupper($3) "\t" toupper($4) "\t" $5 "\t" $6 "\t" $7}' ../taxon-sets/all/het/$uce.het.list > ../cadd_map/$uce.het.forward.liftover.bed
		awk -v "chr=$chr" -v "begin=$begin" -v "uce=$uce" '{print chr "\t" begin+$1 "\t" begin+$1 "\t" toupper($3) "\t" toupper($4) "\t" $5}' ../taxon-sets/all/alt/$uce.hom.list > ../cadd_map/$uce.forward.liftover.bed
	done
done

cut -f 4 chicken.uce.reverse.bed | while read line
do
	grep "${line}$" chicken.uce.reverse.bed | while read chr begin end uce
	do
		awk -v "chr=$chr" -v "end=$end" -v "uce=$uce" '{print chr "\t" end-$1+1 "\t" end+1-$1 "\t" toupper($3) "\t" toupper($4) "\t" $5 "\t" $6 "\t" $7}' ../taxon-sets/all/het/$uce.het.list > ../cadd_map/$uce.het.reverse.liftover.uncompliment.bed
		awk -v "chr=$chr" -v "end=$end" -v "uce=$uce" '{print chr "\t" end-$1+1 "\t" end+1-$1 "\t" toupper($3) "\t" toupper($4) "\t" $5}' ../taxon-sets/all/alt/$uce.hom.list > ../cadd_map/$uce.reverse.liftover.uncompliment.bed
	done
done

cut -f 4 chicken.uce.reverse.bed | while read line
do
	sort -k 1,1 -k 2,2n ../cadd_map/$line.het.reverse.liftover.uncompliment.bed |
	awk '{
               if ($4=="T") sub("T","A",$4);
               else if ($4=="A") sub("A","T",$4);
               else if ($4=="C") sub("C","G",$4);
               else if ($4=="G") sub("G","C",$4);
               print
               }' |
	awk '{
               if ($5=="T") sub("T","A",$5);
               else if ($5=="A") sub("A","T",$5);
               else if ($5=="C") sub("C","G",$5);
               else if ($5=="G") sub("G","C",$5);
               print
               }' |
	awk '{
               if ($7=="T") sub("T","A",$7);
               else if ($7=="A") sub("A","T",$7);
               else if ($7=="C") sub("C","G",$7);
               else if ($7=="G") sub("G","C",$7);
               print
               }' |
        awk '{
               if ($8=="T") sub("T","A",$8);
               else if ($8=="A") sub("A","T",$8);
               else if ($8=="C") sub("C","G",$8);
               else if ($8=="G") sub("G","C",$8);
               print
               }' |
	sed 's/ /\t/g' > ../cadd_map/$line.het.reverse.liftover.bed

	sort -k 1,1 -k 2,2n ../cadd_map/$line.reverse.liftover.uncompliment.bed |
	awk '{
	       	if ($4=="T") sub("T","A",$4);
 	      	else if ($4=="A") sub("A","T",$4);
        	else if ($4=="C") sub("C","G",$4);
        	else if ($4=="G") sub("G","C",$4);
        	print
		}' |
	awk '{
        	if ($5=="T") sub("T","A",$5);
        	else if ($5=="A") sub("A","T",$5);
	       	else if ($5=="C") sub("C","G",$5);
        	else if ($5=="G") sub("G","C",$5);
        	print
		}' |
	sed 's/ /\t/g' > ../cadd_map/$line.reverse.liftover.bed
done

cd ../cadd_map
cut -f 1 ~/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt | while read line; do grep $line hom.liftover.bed| sort -k 1,1n -k 2,2n | awk -F '\t' '{$2=$2-1; print}' OFS=$'\t' | sed "s/\t$//g" > $line.hom.bed; done
cut -f 1 ~/erode/apps/scripts/RefGenPaper/Metadata/Metadata_27sp.txt | while read line; do grep $line het.liftover.bed| awk '{if ($5==$7 && $5!="-") {$2=$2-1; print}}' OFS=$'\t' | sort -k 1,1n -k 2,2n > $line.het.bed; done
