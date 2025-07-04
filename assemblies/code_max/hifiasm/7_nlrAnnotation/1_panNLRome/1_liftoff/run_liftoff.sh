#!/bin/bash

source activate liftoff

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_liftoffResults
	cd $NAME\_liftoffResults
	ln -s ../panNLRome.gff ./
	ln -s ../panNLRome.fasta ./
	liftoff -exclude_partial -g panNLRome.gff -o $NAME.liftoff.gff -u $NAME.unmapped.txt -p 12 -copies ../$i panNLRome.fasta &
	cd ../
done
