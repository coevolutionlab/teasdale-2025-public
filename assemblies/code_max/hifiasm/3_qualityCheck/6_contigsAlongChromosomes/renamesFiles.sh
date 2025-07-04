#!/bin/bash

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	for i in $(ls chr*.contigs*); do
		NAME2=$(echo $i)
		mv $NAME2 $NAME.$NAME2
	done
	echo $NAME
	cd ../
done
