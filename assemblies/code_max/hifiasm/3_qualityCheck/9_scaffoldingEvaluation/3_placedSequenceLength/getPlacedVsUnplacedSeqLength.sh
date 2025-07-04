#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	PLACED=$(seqtk comp $i | awk '$1 ~/^Chr/ {print $1, $2}' | awk '{sum+=$2}END{print sum;}')
	UNPLACED=$(seqtk comp $i | awk '$1 !~/^Chr/ {print $1, $2}' | awk '{sum+=$2}END{print sum;}')
	echo $NAME $PLACED $UNPLACED
done
