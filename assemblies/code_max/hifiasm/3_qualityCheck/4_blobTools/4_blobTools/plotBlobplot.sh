#!/bin/bash

source activate blob

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	cd $NAME\_blobtoolsResults
#	blobtools plot -i $NAME.primaryContigs.blobplot.blobDB.json -o ./ &
	blobtools plot -r genus -o $NAME.genus.blobplot -i $NAME.primaryContigs.hifiasm.blobplot.blobDB.json & 
	cd ../
done
