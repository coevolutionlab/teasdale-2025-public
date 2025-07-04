#!/bin/bash

for file in $(ls *4R); do
	TYPE=$(echo $file | awk -F'.4R' '{print $1}')
	for i in $(cat $file | awk '{print $3}' | sort | uniq); do
		grep $i $file | awk -v pat="$i" '{print $1, $2, pat}' > $TYPE.$i.list
	done
#	for acc in $(cat acc.list); do
#		echo $acc > $acc.nlr.
#		grep $acc *.*.list | awk -F':' '{print $2}' 
#	done
done


