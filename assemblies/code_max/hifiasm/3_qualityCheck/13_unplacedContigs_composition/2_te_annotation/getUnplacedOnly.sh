#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^Chr/ {print}' > $NAME.TEsUnplacedContigs.gff
done
