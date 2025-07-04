#!/bin/bash

for i in $(ls at*.scaffolds.fasta); do
	samtools faidx $i &
done
