#!/bin/bash

for i in $(ls at*.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_syriResults
	cat $NAME.syri.out \
	| awk -v pat=$NAME '$11 == "INS" {print pat, "Insertion", ($8 - $7)}'
	cat $NAME.syri.out \
	| awk -v pat=$NAME '$11 == "DEL" {print pat, "Deletion", ($8 - $7)}'
	cd ../
done 
