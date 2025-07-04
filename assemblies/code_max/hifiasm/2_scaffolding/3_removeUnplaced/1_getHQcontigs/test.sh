#!/bin/bash

for i in $(ls at9900.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $NAME.scaffolds.bionano.hifiasm.final.fasta | awk '{print $1, $2}' > $NAME.length
	for line in $(cat $NAME.names.txt); do
		grep $line $NAME.length > $NAME.test.results
	done
	cat $NAME.test.results | awk '{sum+=$2} END {print sum}'
done
