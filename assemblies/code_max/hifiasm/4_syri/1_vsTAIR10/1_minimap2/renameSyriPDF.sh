#!/bin/bash

for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_syriResults
	mv syri.pdf $NAME.hifiasm_vs_tair10.syri.pdf
	cd ../
done
