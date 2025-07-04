#!/bin/bash

for i in $(ls at*.fastq); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_hifiasmResults
	cd $NAME\_hifiasmResults
	hifiasm -l0 -f0 -t32 -o $NAME.hifiasm ../$i &
	cd ../ 
done

