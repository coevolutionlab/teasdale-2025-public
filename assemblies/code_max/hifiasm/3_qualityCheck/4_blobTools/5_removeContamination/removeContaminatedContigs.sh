#!/bin/bash

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk subseq $i $NAME.cleanContigs >> $NAME.p_ctg.noContamination.hifiasm.fasta &
done


