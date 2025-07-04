#!/bin/bash

for i in $(ls at*.protein.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_buscoOUT/$NAME\_buscoResults/run_embryophyta_odb10
	cp full_table.tsv $NAME.full_table.tsv
	cd ../../../
done
