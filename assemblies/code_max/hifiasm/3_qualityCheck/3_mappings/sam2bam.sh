#!/bin/bash

for i in $(ls at*.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	cd $NAME\_mappings
	nice -n5 samtools view -@ 20 -S -b $NAME.mappings.primaryContigs.sam >> $NAME.mappings.primaryContigs.bam &
	cd ../
done
