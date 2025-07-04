#!/bin/bash

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults
	mv ragtag.correction.agp $NAME.tair10.correction.agp
	cd ../
done
