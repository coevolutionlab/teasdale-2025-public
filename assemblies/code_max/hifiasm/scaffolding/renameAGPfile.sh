#!/bin/bash

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults
	cp ragtag.scaffolds.agp $NAME.hifiasm.scaffolds.agp
	cd ../
done
