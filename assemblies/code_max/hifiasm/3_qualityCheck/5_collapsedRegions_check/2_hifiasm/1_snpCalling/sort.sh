#!/bin/bash

for i in $(ls at*.mappings.hifiasm.scaffolds.bam); do
	NAME=$(echo $i | awk -F'.bam' '{print $1}')
	nice samtools sort --threads 50 $i > $NAME.sorted.bam
done
