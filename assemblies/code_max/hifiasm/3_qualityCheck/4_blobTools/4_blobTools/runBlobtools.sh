#!/bin/bash

source activate blob

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_blobtoolsResults
	cd $NAME\_blobtoolsResults
	blobtools create -i ../$i -b ../$NAME.mappings.hifiasm.p_ctg.sorted.bam -t ../$NAME.hifiasm.primaryContigs.m8 -o $NAME.primaryContigs.hifiasm.blobplot &
	cd ../
done
