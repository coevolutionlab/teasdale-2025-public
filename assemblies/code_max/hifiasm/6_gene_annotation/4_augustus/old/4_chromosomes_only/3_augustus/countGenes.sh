#!/bin/bash

for i in $(ls at*gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" {print}' | wc -l)
	echo $NAME $NO
done
