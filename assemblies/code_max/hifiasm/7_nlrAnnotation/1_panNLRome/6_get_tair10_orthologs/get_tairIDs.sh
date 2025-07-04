#!/bin/bash

for file in $(ls at*.nlr.liftoff.gff); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	for line in $(cat nlr.IDs.txt); do
		grep $line $file >> $NAME.tair10.IDs
	done
	echo $NAME
done
