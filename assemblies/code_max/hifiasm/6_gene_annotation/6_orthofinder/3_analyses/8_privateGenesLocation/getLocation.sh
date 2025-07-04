#!/bin/bash

for i in $(ls at*.private.IDs); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk -F'_' '{print $2}' > $NAME.private.tmp
	for line in $(cat $NAME.private.tmp); do
		grep -w "$line" $NAME.softmasked.final.gff3 | awk '$1 !~/^#/ {print $1}' | uniq >> $NAME.privateGenes.location
	done
	rm $NAME.private.tmp
done
