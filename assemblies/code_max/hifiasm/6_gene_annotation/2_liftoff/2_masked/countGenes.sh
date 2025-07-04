#!/bin/bash

echo "geneCount unmapped multiCopy"

for i in $(ls at*.softmasked.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_liftoffResults
	GC=$(cat $NAME.liftoff.gff | awk '$3 == "gene"' | wc -l)
	UM=$(cat $NAME.unmapped.txt | wc -l)
	MC=$(cat $NAME.liftoff.gff |  awk '$3 == "gene"' | awk -F';' '{print $6}' | awk -F'=' '$2 >0' | wc -l)
	echo $NAME $GC $UM $MC
	cd ../
done
