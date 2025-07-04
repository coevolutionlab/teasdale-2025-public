#!/bin/bash

for i in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk subseq $i chr1to5.list > $NAME.hifiasm.chr1to5.fasta
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.hifiasm.chr1to5.fasta
done
