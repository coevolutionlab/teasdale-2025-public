#!/bin/bash

source activate minimap2


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	grep '>' $i | sed 's/>//g' | awk '$1 !~/^Chr/' > $NAME.unplaced.ids
	seqtk subseq $i $NAME.unplaced.ids > $NAME.unplaced.fasta 
done


for i in $(ls at*.unplaced.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	minimap2 -t 12 -cx asm5 chrM.fasta $i > $NAME.chrM.paf &
done

for i in $(ls at*.unplaced.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        minimap2 -t 12 -cx asm5 chrC.fasta $i > $NAME.chrC.paf &
done


