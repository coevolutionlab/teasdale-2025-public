#!/bin/bash

for i in $(ls at*.hifiASM.p_ctg.fasta.fai); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults
	cp ragtag.patch.agp $NAME.patch.agp
	cd ../
done
