#!/bin/bash

for i in $(ls at*.sorted.bam); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	samtools depth $i | awk '{sum+=$3} END { print "Average = ",sum/NR}' > $NAME.samtools.depth &
done
