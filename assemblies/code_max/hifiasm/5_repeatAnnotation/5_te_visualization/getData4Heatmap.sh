#!/bin/bash

for i in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | head -n5 | awk '{print $1, $2}' | sed 's/\_RagTag\_RagTag//g' | sed 's/ /\t/g' > $NAME.chrSize.txt
	cat $NAME.edta_clean.filtered.gff | awk '{print $1, $4, $5, "gene"}' | sed 's/ /\t/g' > $NAME.te.map
	sed -i '1ichrom	start	end	feature' $NAME.te.map
done

