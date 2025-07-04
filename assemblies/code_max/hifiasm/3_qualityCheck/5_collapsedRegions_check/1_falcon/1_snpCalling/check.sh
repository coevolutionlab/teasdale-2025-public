#!/bin/bash

for i in $(ls at*sorted.bam); do
	samtools quickcheck $i 
done
