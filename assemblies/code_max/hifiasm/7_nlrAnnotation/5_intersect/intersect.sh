#!/bin/bash

for i in $(ls at*.softmasked.final.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/ && $3 == "gene"' > $NAME.augustus.genes.gff
	cat $NAME.nlr.liftoff.gff | awk '$3 == "gene"' | grep "NLR=" > $NAME.liftoff.nlr.gff
	cat $NAME.nlr.txt | awk '$3 == "complete" {print $1, $5, $6, $2, $3, $7, $8}' | sed 's/ /\t/g' > $NAME.nlr.parser.bed
	bedtools intersect -wao -a $NAME.liftoff.nlr.gff -b $NAME.augustus.genes.gff | cut -f1,2,3,4,5,6,7,8,9,18 > $NAME.nlrIntersect.gff 
	bedtools intersect -wa -b $NAME.liftoff.nlr.gff -a $NAME.augustus.genes.gff | awk -F'\t' '{print $9}' | awk -F'|' '{print $1}' | awk -F'=' '{print $2}'  > $NAME.augustus.ids &
	bedtools intersect -wa -a $NAME.nlrIntersect.gff -b $NAME.nlr.parser.bed > $NAME.nlrIntersect.nlRome.parser.augustus.gff &
	bedtools intersect -wa -a $NAME.liftoff.nlr.gff -b $NAME.nlr.parser.bed > $NAME.nlrIntersect.nlRome.parser.gff &
	bedtools intersect -wa -a $NAME.augustus.genes.gff -b $NAME.nlr.parser.bed > $NAME.nlrIntersect.parser.augustus.gff &
done
