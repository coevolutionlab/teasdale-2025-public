#!/bin/bash

echo "genotype loss gain conserved"

for i in $(ls at*.ogs); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	LOSS=$(cat $i | awk -F';' '$1 > $2' | wc -l)
	GAIN=$(cat $i | awk -F';' '$1 < $2' | wc -l)
	CONSERVED=$(cat $i | awk -F';' '$1 == $2' | wc -l)
	echo $NAME $LOSS $GAIN $CONSERVED
done
