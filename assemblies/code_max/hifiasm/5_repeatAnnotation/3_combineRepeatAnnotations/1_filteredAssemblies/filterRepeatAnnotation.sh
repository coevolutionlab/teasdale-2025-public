#!/bin/bash

for i in $(ls at*.contigs2keep); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for line in $(cat $i); do
		#awk -v pat="$line" '$1 ~/^pat/' $NAME.edta.cleaned.gff >> $NAME.edta_cleaned.filtered.gff &
		grep -w "$line" $NAME.edta.cleaned.gff >> $NAME.edta_clean.filtered.gff 
	done 
	echo $NAME "processed"
done
