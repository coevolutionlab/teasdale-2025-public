#!/bin/bash

for line in $(cat r_genes.full_set.list.updated20200321.csv); do
	GENE=$(echo $line | awk -F',' '{print $1}')
	grep $GENE *new.4R | awk -v gene="$GENE" -F':' '{print $1, gene}' | sort | uniq 
done
