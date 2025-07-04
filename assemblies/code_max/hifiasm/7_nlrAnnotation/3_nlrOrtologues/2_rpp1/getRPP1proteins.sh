#!/bin/bash

for i in $(ls at*.protein.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk subseq $i $NAME.rpp1_orthologs.txt > $NAME.rpp1.protein.fasta &
done
