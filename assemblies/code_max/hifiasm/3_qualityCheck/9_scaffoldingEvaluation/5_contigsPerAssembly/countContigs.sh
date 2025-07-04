#!/bin/bash

for i in $(ls at*agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | awk '$1 ~/^Chr/ && $5 == "W"' | wc -l)
	echo $NAME $NO
done
