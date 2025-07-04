#!/bin/bash

for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_syriResults
	cat $NAME.syri.summary \
	| head -n9 \
	| awk -v pat=$NAME -F'\t' '$1 !~/^#/ && $1 !~ "reference" {print pat, $1, $4}' \
	| sed 's/(query) //g' \
	| sed 's/tenic regions/tenic_regions/g' \
	| sed 's/Not ali/Not_ali/g' \
	| sed 's/ /;/g'
	cd ../
done


