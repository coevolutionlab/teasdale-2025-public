#!/bin/bash

for i in $(ls at*chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | awk '{print $1, $2}' > $NAME.chr.length
	echo $NAME "chr length calculated"
done

for i in $(ls at*.chr.length); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	awk '$1 ~/^Chr1/ {print $2}' $i >> chr1.length
	awk '$1 ~/^Chr2/ {print $2}' $i >> chr2.length
	awk '$1 ~/^Chr3/ {print $2}' $i >> chr3.length
	awk '$1 ~/^Chr4/ {print $2}' $i >> chr4.length
	awk '$1 ~/^Chr5/ {print $2}' $i >> chr5.length
done

for i in $(ls chr*.length); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | sort -h | tail -n1)
	echo $NAME $NO
	echo $NAME $NO >> chr.length.summary
done
