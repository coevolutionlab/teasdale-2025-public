#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
MAP="/ebio/abt6/mcollenberg/miniconda3/bin/minimap2"


for i in $(ls at*_polished.fasta); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	mkdir $NAME\_mappings
	cd $NAME\_mappings
	$QSUB 20 5 $MAP -t 20 -a -H -x asm20 ../$i ../$NAME.*Q20*fasta -o $NAME.mappings.primaryContigs.sam &
	cd ../
done
