#!/bin/bash

for i in $(ls at*.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk subseq $i chr1to5.list > $NAME.chr1to5.fasta &
done
