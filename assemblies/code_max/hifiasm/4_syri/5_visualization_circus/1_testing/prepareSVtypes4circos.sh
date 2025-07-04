#!/bin/bash

rm at*.*.bed

for file in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	seqtk comp $file | awk '$1 ~/^Chr/ {print $1, $2}' | sed 's/\_RagTag\_RagTag//g' | sed 's/ /\t/g' > $NAME.genome.index
	cat $NAME.genome.index | awk '{print $1, "0", $2}' | sed 's/ /\t/g' > $NAME.genome.4circos
	bedtools makewindows -w 100000 -g $NAME.genome.index > $NAME.windows.bed
done


for file in $(ls at*.syri.out); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	for line in $(cat svTypes.reduced.list); do
		grep -w $line $file | awk '$1 !~/^-/ {print $1, $7, $8}' | sed 's/ /\t/g' >> $NAME.$line.bed
	done
done


for line in $(cat svTypes.reduced.list); do
	for file in $(ls at*.$line.bed); do
		NAME=$(echo $file | awk -F'.' '{print $1}')
		bedtools intersect -c -a $NAME.windows.bed -b $file > $NAME.$line.out
	done
done
