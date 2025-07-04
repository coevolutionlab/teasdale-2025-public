#!/bin/bash

for line in $(cat Orthogroups.txt | awk 'NF==2 {print $2}' | awk -F'_' '{print $1}' | sort | uniq); do
	echo $line
	cat Orthogroups.txt | awk 'NF==2 {print $2}' | grep $line > $line.private.IDs
	echo "private" > $line.privateGenes.length
	for i in $(cat $line.private.IDs); do
		grep $i $line.protein.length | awk '{print $2}' >> $line.privateGenes.length
	done
done
