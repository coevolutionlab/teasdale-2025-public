#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.centromeres
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.telomeres
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.5S_rDNA
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.45S_rDNA
	cd ../
	echo $NAME
done
