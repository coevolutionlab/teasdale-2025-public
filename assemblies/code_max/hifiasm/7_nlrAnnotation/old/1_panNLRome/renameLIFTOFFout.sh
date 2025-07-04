#!/bin/bash

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_liftoffResults
	cp $NAME.liftoff.gff $NAME.nlr.liftoff.gff
	cd ../
done
