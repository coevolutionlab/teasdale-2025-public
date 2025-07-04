#!/bin/bash

for i in $(ls at*.nlr.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$3 == "gene" && $1 ~/^Chr/' | grep "NLR=" | awk 'OFS="\t" {print $1, $4, $5}' > $NAME.nlr.genes.bed
	cat $NAME.snp.summary.final | sed 's/ /\t/g' > $NAME.snp.bed
	echo $NAME "done"
done

for i in $(ls at*.nlr.genes.bed); do
	NAME=$(echo $i | awk -F"." '{print $1}')
	bedtools intersect -wa -a $NAME.nlr.genes.bed -b $NAME.snp.bed > $NAME.nlr_snp.intersect.txt
	bedtools intersect -wb -a $NAME.nlr.genes.bed -b $NAME.snp.bed > $NAME.snp_nlr.intersect.txt
	echo $NAME "intersected"
done
