#!/bin/bash

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	mv $NAME.karyoplot.png $NAME.karyoplot.hifiasm.png
	cd ../
	echo $NAME
done
