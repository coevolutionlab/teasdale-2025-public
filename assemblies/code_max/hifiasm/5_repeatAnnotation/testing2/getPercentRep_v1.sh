#!/bin/bash

for i in $(ls at*.repeatAnnotation.sorted.merged.bed); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $NAME.scaffolds.bionano.hifiasm.final.fasta | awk '{print $1, $2}' > $NAME.comp
	cat $i | awk '{print $1}' | sort | uniq | awk '$1 !~/^Chr/' > $NAME.unplacedContigs.ids
	echo "occupied;total" > $NAME.final.tmp
	for line in $(cat $NAME.unplacedContigs.ids); do
		grep $line $i | awk '{print ($3-$2)}' | awk '{sum+=$1} END {print sum}' > $NAME.$line.occupiedSequence
		grep $line $NAME.comp | awk '{print $2}' > $NAME.$line.totalLength
		paste $NAME.$line.occupiedSequence $NAME.$line.totalLength >> $NAME.final.tmp
	done
	cat $NAME.final.tmp | awk '$1 !~/^occupied/ {print $1, $2, $3=100*$1/$2}' > $NAME.final
done
