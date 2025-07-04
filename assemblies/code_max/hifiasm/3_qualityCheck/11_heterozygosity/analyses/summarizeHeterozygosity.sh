#!/bin/bash

for i in $(ls at*summary.txt); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	HET=$(cat $i | awk '$1 ~/^Heterozygosity/ {print $2, $3}')
	echo $NAME $HET
done
