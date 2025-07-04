#!/bin/bash

source activate blob

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_blobtoolsResults
	blobtools view -r genus -i $NAME.primaryContigs.hifiasm.blobplot.blobDB.json -o $NAME.primaryContigs.genus &
	cd ../
done
