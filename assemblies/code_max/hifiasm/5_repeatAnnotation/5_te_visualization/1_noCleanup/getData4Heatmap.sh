#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i| awk '$1 !~/^#/ {print $1, $4, $5, "gene"}' | sed 's/\_RagTag\_Rag//g'| sed 's/ /\t/g' > $NAME.te.map
	sed -i '1ichrom	start	end	feature' $NAME.te.map
done

