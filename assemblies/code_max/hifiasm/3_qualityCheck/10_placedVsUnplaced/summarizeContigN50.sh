#!/bin/bash

echo "genotype,placed,unplaced" >> placedUnplacedN50.4R

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	PLACED=$(cat $NAME.placedContigs.N50 | grep 'N50' | awk -F'>=' '{print $2}')
	UNPLACED=$(cat $NAME.unplacedContigs.N50 | grep 'N50' | awk -F'>=' '{print $2}')
	echo $NAME $PLACED $UNPLACED
	echo $NAME $PLACED $UNPLACED >> placedUnplacedN50.4R
done

sed -i -e 's/ /,/g' placedUnplacedN50.4R
