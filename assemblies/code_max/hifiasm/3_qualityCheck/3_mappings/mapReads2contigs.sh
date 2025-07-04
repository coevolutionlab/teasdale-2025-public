#!/bin/bash

for i in $(ls at*_polished.fasta); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	mkdir $NAME\_mappings
	cd $NAME\_mappings
	minimap2 -t 12 -a -H -x map-pb ../$i ../$NAME.*Q20*fasta >> $NAME.mappings.unplacedContigs.sam &
	cd ../
done
