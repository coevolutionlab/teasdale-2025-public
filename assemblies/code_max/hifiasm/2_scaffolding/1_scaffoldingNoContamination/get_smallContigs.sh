#!/bin/bash


for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | awk '{print $1, $2}' | awk '$2 < 100000 {print $1}' > $NAME.contigs.u100kb.ids
	seqtk subseq $i $NAME.contigs.u100kb.ids > $NAME.smallContigs.u100kb.fasta &
done
