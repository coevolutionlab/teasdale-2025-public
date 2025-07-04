#!/bin/bash

for i in $(ls at*scaffolds.fasta.mod.EDTA.TEanno.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/ {print $1}' | sort | uniq > $NAME.sorted.edta.IDs
	cat $NAME.scaffolds.fasta.out.gff | awk '$1 !~/^#/ {print $1}' | sort | uniq > $NAME.sorted.repeatMasker.IDs
	bedtools sort -faidx $NAME.sorted.edta.IDs -i $i > $NAME.edta.sorted.gff
	bedtools sort -faidx $NAME.sorted.repeatMasker.IDs -i $NAME.scaffolds.fasta.out.gff > $NAME.repeatMasker.sorted.gff
	bedtools intersect -v -a $NAME.edta.sorted.gff -b $NAME.repeatMasker.sorted.gff > $NAME.edta.cleaned.gff
	bedtools intersect -wa -wb -a $NAME.edta.sorted.gff -b $NAME.repeatMasker.sorted.gff > $NAME.edta_repeatMasker.intersect.gff
	rm $NAME.edta.sorted.gff
	rm $NAME.repeatMasker.sorted.gff
	rm $NAME.sorted.edta.IDs
	rm $NAME.sorted.repeatMasker.IDs
done
