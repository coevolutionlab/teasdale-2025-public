#!/bin/bash


for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | awk '{print $1, $2}' | awk '$2 >= 100000 {print $1}' > $NAME.contigs100kb.ids
	seqtk subseq $i $NAME.contigs100kb.ids > $NAME.largeContigs100kb.fasta &
done
