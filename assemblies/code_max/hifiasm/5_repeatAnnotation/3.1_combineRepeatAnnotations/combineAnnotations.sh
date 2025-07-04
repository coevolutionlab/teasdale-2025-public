#!/bin/bash

for i in $(ls at*.edta.cleaned.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	cat $i $NAME.scaffolds.bionano.hifiasm.final.fasta.out.gff  > $NAME.repeatAnnotation.gff.tmp
	bedtools sort -i $NAME.repeatAnnotation.gff.tmp > $NAME.repeatAnnotation.gff
	rm $NAME.repeatAnnotation.gff.tmp
done
