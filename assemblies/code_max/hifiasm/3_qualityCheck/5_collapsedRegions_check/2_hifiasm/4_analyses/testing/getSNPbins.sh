#!/bin/bash

for i in $(ls at*.calls.vcf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bcftools view -m2 -M2 -v snps $i | awk '$1 !~ /^#/ && $1 ~/^Chr/' > $NAME.snps
	seqtk comp $NAME.scaffolds.bionano.hifiasm.final.fasta | awk '$1 ~/^Chr/ {print $1, $2}' | sed 's/ /\t/g' > $NAME.coordinates
	cat $NAME.snps | awk '{print $1, $2, $2, "1"}' | sed 's/ /\t/g' > $NAME.snps.bed
	bedtools makewindows -g $NAME.coordinates -w 5000 > $NAME.coordinates4bedtools
	bedtools map -a $NAME.coordinates4bedtools -b $NAME.snps.bed -c 4 -o sum > $NAME.snps.final.tmp
	cat $NAME.snps.final.tmp | awk '$4 !="."' > $NAME.snps.final
	cat $NAME.snps | awk -F';' '{print $1}' | awk '{print $1, $2, $2, $8}' | sed 's/DP=//g' | sed 's/ /\t/g' > $NAME.snps.depth
	bedtools map -a $NAME.coordinates4bedtools -b $NAME.snps.depth -c 4 -o mean > $NAME.snps.depth.bin.tmp
	cat $NAME.snps.depth.bin.tmp | awk '$4 !="."' > $NAME.snps.depth.bin
	paste $NAME.snps.depth.bin $NAME.snps.final | awk '{print $1, $2, $3, $4, $8}' > $NAME.snp.summary
	rm $NAME.snps.depth.bin.tmp
#	rm $NAME.snps.bed
	rm $NAME.coordinates
	rm $NAME.snps.final.tmp
	rm $NAME.coordinates4bedtools
done

