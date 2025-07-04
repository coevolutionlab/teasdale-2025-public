#!/bin/bash

source activate ragtag2

for i in $(ls at*.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_ragtagResults
	cd $NAME\_ragtagResults
	ragtag.py patch --fill-only -t 30 -o ./ ../$i ../$NAME.hifiASM.p_ctg.fasta & 
	cd ../
done
