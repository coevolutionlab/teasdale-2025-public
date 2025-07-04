#!/bin/bash

for i in $(ls at*.scaffolds.fasta.mod.EDTA.TEanno.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	for line in $(cat $i | awk '$1 !~/^#/ {print $3}' | sort | uniq); do
		cat $i | grep $line | awk '{print ($5-$4)}' | awk -v pat="$line" '{s+=$1;}END{print "all",pat,s}' >> $NAME.sum.tmp
		cat $NAME.edta.cleaned.gff | grep $line | awk '{print ($5-$4)}' | awk -v pat="$line" '{s+=$1;}END{print "clean", pat,s}' >> $NAME.sum.tmp
		echo $line
	done
done

for i in $(ls at*.sum.tmp); do
	NAME=$(echo $i | awk -F'.' '{print $1}' | sed 's/at/AT/g')
	cat $i | awk -v pat="$NAME" '$1 =="clean" {print pat, $2, $3}' >> repeatSummary.4R
	cat $i | awk -v pat="$NAME" '$1 =="all" {print pat, $2, $3}' >> repeatSummary.nocleanup.4R
	echo $NAME "done"
	rm $i
done

