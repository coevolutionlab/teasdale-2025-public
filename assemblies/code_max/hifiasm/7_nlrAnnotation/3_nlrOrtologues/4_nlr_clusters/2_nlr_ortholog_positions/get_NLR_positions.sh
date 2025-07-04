#!/bin/bash

for file in $(ls at*.softmasked.final.gff3); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	cat $file | awk '$1 !~/^#/ && $3 == "gene" {print $1, $4, $5, $9}' | sed -e 's/ID=//g' > $NAME.all.genes.txt
	for line in $(cat $NAME.nlrOG.txt); do
		ID=$(echo $line)
		grep $ID $NAME.all.genes.txt >> $NAME.nlr.positions.bed
	done
	rm $NAME.all.genes.txt
done
