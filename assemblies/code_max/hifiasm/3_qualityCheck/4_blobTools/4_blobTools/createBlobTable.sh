#!/bin/bash

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_blobtoolsResults
	echo $NAME
	blobtools view -i $NAME.primaryContigs.hifiasm.blobplot.blobDB.json -o ./ &
	cd ../
done
