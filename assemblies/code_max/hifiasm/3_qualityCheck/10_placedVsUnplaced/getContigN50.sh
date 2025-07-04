#!/bin/bash

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	perl countFasta.pl $NAME.placedContigs.fasta >> $NAME.placedContigs.N50 &
	perl countFasta.pl $NAME.unplacedContigs.fasta >> $NAME.unplacedContigs.N50 &
done
