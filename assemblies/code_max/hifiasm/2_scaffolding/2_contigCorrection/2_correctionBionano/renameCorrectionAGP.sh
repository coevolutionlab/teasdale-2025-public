#!/bin/bash

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults
	mv $NAME.correction.agp $NAME.bionano.correction.agp
	cd ../
done
