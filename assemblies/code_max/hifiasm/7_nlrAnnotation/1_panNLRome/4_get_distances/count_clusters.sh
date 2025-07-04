#!/bin/bash

for file in $(ls at*.nlr.distances); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	TOTAL=$(cat $file | wc -l)
	CLUST=$(cat $file | awk '$1 <= 200000' | wc -l)
	echo $NAME $TOTAL $CLUST
done
