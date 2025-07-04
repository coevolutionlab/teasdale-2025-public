#!/bin/bash

for i in $(ls at*scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools maskfasta -soft -fi $i -bed $NAME.repeatAnnotation.gff -fo $NAME.softmasked.final.fasta &
done
