#!/bin/bash

for i in $(ls at*.CCS.*fastq); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	hifiasm -l0 -f0 -t32 -o $NAME.hifiasm $i 
done

