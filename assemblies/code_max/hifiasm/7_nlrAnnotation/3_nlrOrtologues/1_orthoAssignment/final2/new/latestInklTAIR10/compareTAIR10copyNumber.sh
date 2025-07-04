#!/bin/bash

grep 'TAIR10' *4R | awk -F':' '{print $2}' | awk '$1 != 1 {print $1, $2, $3}'| sed 's/ /;/g'  > tair10_nlr.tmp

for line in $(cat tair10_nlr.tmp); do
	GENE=$(echo $line | awk -F';' '{print $3}')
	NO=$(grep $GENE genome.gff3 | awk '$3  == "gene"' | wc -l)
	NO2=$(echo $line | awk '{print $1}')
	echo $GENE $NO $NO2
done
