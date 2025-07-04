#!/bin/bash

#for i in $(ls at*.*.length); do
#	NAME=$(echo $i | awk -F'.' '{print $1}')
#	ls at*.*.length > types.txt
#	cat types.txt | awk -F'.' '{print $2}' | sort | uniq > types.uniq.txt
#	for line in $(cat types.uniq.txt); do
#		paste at*.$line.length | sed 's/\t/;/g' > $line.summary.4R
#	done
#done


for type in $(ls at*.*.length | awk -F'.' '{print $2}' | sort | uniq); do
	paste at*.$type.length | sed 's/\t/;/g' > $type.summary.4R
	echo $type
done
