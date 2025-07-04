#!/bin/bash

source activate ragtag2

for i in $(ls at*_polished.fasta); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	mkdir $NAME\_ragtagResults
	cd $NAME\_ragtagResults
	ragtag.py patch -t 30 -o ./ ../$NAME.hifiASM.p_ctg.fasta ../$i &
	cd ../
done
