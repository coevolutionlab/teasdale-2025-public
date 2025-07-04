#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk subseq $i $NAME.contigs2keep > $NAME.scaffolds.bionano.final.fasta &
done
