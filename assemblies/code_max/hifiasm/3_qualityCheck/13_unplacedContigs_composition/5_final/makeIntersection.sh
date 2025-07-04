#!/bin/bash

for i in $(ls at*.chrM.chrC.final.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools sort -i $i > $NAME.organellar.sorted.gff
	bedtools sort -i $NAME.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3 > $NAME.TEs.sorted.gff
	bedtools sort -i $NAME.scaffolds.bionano.hifiasm.final.fasta.out.gff > $NAME.repeats.sorted.gff
	bedtools intersect -v -a $NAME.repeats.sorted.gff -b $NAME.organellar.sorted.gff > $NAME.repeats.sorted.vOrganellar.gff
	cat $NAME.organellar.sorted.gff $NAME.repeats.sorted.vOrganellar.gff > $NAME.organellar.repeats.gff
	bedtools sort -i $NAME.organellar.repeats.gff > $NAME.organellar.repeats.sorted.gff
	bedtools intersect -v -a $NAME.TEs.sorted.gff -b $NAME.organellar.repeats.sorted.gff > $NAME.TEs.sorted.vOrganellar.vRepeats.gff
	cat $NAME.organellar.repeats.sorted.gff $NAME.TEs.sorted.vOrganellar.vRepeats.gff | awk '$1 !~/^Chr/ && $1 !~/#/ {print}' > $NAME.unplacedContigs.annotation.gff
done
