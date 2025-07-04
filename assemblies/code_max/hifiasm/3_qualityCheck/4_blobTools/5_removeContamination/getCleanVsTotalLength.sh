#!/bin/bash

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	perl countFasta.pl $i > $NAME.fullLength.tmp 
	perl countFasta.pl $NAME.p_ctg.noContamination.hifiasm.fasta > $NAME.cleanLength.tmp
	TOTAL=$(cat $NAME.fullLength.tmp | awk '$1 ~/^Total/' | awk '{print $5}' | head -n1)
	CLEAN=$(cat $NAME.cleanLength.tmp | awk '$1 ~/^Total/' | awk '{print $5}' | head -n1)
	echo $NAME $TOTAL $CLEAN
done
