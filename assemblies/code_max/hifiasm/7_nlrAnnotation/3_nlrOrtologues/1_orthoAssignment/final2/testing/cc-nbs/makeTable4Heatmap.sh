#!/bin/bash

for i in $(ls CC-NBS.4R); do
	TYPE=$(echo $i | awk -F'.' '{print $1}')
	for acc in $(cat $i | awk '{print $2}' | sort | uniq); do
		grep $acc $i
	done
done
