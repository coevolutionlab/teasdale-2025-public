#!/bin/bash

source activate blob

for i in $(ls at*_polished.fasta); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	cd $NAME\_blobtoolsResults
	blobtools view -r phylum -i $NAME.primaryContigs.blobplot.blobDB.json -o $NAME.primaryContigs.phylum &
	cd ../
done
