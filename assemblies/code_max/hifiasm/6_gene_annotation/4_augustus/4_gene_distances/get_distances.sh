#!/bin/bash

for i in $(ls at*.softmasked.final.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for chr in $(cat $i | awk '$1 !~/^ptg/ && $1 !~/^#/ {print $1}' | sort | uniq); do
		grep $chr $i | awk '$3 == "gene" {print $4}' | sed -e '1 d' > $NAME.$chr.start.tmp
		grep $chr $i | awk '$3 == "gene" {print $5}' | sed -e '$ d' > $NAME.$chr.end.tmp 
		paste $NAME.$chr.start.tmp $NAME.$chr.end.tmp | awk '{print $1-$2}' > $NAME.$chr.distances
	done
	cat $NAME.Chr*.distances > $NAME.gene.distances
	rm $NAME.Chr*.distances
	echo $NAME
done
