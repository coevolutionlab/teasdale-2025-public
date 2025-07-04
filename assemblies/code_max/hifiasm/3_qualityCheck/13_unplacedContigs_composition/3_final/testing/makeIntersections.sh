#!/bin/bash

for i in $(ls at*.chrM.chrC.final.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $NAME.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3 | awk '$1 !~/^Chr/ && $1 !~/^#/ {print}' > $NAME.unplaced.TEs.gff
	cp $i $NAME.unplaced.organellar.gff
	cat $NAME.scaffolds.bionano.hifiasm.final.fasta.out.gff | awk '$1 !~/^Chr/ && $1 !~/^#/ {print}' > $NAME.unplaced.repeats.gff
	bedtools intersect -v -a $NAME.unplaced.repeats.gff -b $NAME.unplaced.organellar.gff > $NAME.unplaced.repeats.vOrganellar.gff
	cat $NAME.unplaced.organellar.gff $NAME.unplaced.repeats.vOrganellar.gff > $NAME.unplaced.organellar.repeats.gff
	bedtools intersect -v -a $NAME.unplaced.TEs.gff -b $NAME.unplaced.organellar.repeats.gff > $NAME.unplaced.TEs.vOrgnellar.vRepeats.gff
	cat $NAME.unplaced.organellar.repeats.gff $NAME.unplaced.TEs.vOrgnellar.vRepeats.gff > $NAME.unplacedContigsAnnotation.gff
done
