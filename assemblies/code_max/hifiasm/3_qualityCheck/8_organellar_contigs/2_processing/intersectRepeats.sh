#!/bin/bash

for i in $(ls at*chrM.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -v -a $i -b $NAME.chrC.gff > $NAME.chrM.v.gff
	bedtools intersect -v -a $NAME.chrC.gff -b $i > $NAME.chrC.v.gff
	cat $NAME.chrM.v.gff $NAME.chrC.v.gff > $NAME.chrC.chrM.gff
	bedtools sort -i $NAME.chrC.chrM.gff > $NAME.chrC.chrM.sorted.gff
	bedtools intersect -v -a $NAME.scaffolds.bionano.hifiasm.final.fasta.out.gff -b $NAME.chrC.chrM.sorted.gff > $NAME.centromere.v.gff
	bedtools sort -i $NAME.centromere.v.gff > $NAME.centromere.v.sorted.gff
	cat $NAME.chrC.chrM.gff $NAME.centromere.v.sorted.gff > $NAME.chrC.chrM.centromere.gff
	bedtools sort -i $NAME.chrC.chrM.centromere.gff > $NAME.chrC.chrM.centromere.sorted.gff
	bedtools intersect -v -a $NAME.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3 -b $NAME.chrC.chrM.centromere.sorted.gff > $NAME.tes.v.gff
	cat $NAME.chrC.chrM.centromere.sorted.gff $NAME.tes.v.gff > $NAME.final.gff
	echo $NAME "done"
done


for i in $(ls at*.final.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | awk '$1 !~/^Chr/ {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	echo $NAME $NO
done
