#!/bin/bash

for i in $(ls at*correction.agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TYPE=$(echo $i | awk -F'.' '{print $2}')
	NO=$(cat $i | awk '$1 !~/^#/ {print $1}' | sort | uniq -c | awk '$1 !=1' | wc -l)
	echo $NAME $TYPE $NO
done
