#!/bin/bash

for i in $(ls hybrid*_at*Aligned.sortedByCoord.out.bam); do
	NAME=$(echo $i | awk -F"A" '{print $1}' | awk -F'_' '{print $2}')
	echo $NAME
	samtools view -@ 5 -h -o $NAME.hybridNecrosis.sam $i &
done
