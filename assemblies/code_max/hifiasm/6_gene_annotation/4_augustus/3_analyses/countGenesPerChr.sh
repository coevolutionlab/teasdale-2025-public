#!/bin/bash

for i in $(ls at*gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" {print}' | wc -l)
	CHR1=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 ~/^Chr1/ {print}' | wc -l)
	CHR2=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 ~/^Chr2/ {print}' | wc -l)
	CHR3=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 ~/^Chr3/ {print}' | wc -l)
	CHR4=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 ~/^Chr4/ {print}' | wc -l)
	CHR5=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 ~/^Chr5/ {print}' | wc -l)
	UNP=$(cat $i | awk '$1 !~/^#/ && $3 == "gene" && $1 !~/^Chr/ {print}' | wc -l)
	echo $NAME $NO $CHR1 $CHR2 $CHR3 $CHR4 $CHR5 $UNP
done

