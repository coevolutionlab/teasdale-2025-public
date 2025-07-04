#!/bin/bash

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr/' | awk '$5 == "W" {print $6}' >> $NAME.placedIDs
	seqtk subseq $i $NAME.placedIDs >> $NAME.placedContigs.fasta &
	grep '>' $i | sed 's/>//g' | awk -F' ' '{print $1}' >> $NAME.allIDs
	cat $NAME.placedIDs $NAME.allIDs | sort | uniq -c | awk '$1 == 1 {print $2}' >> $NAME.unplacedIDs
	seqtk subseq $i $NAME.unplacedIDs >> $NAME.unplacedContigs.fasta &
	echo $NAME
done
