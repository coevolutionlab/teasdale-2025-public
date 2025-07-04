#!/bin/bash

for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_syriResults
	mv syri.out $NAME.syri.out
	cd ../
done
