#!/bin/bash

for NAME in $(cat alignment.list | awk -F'.' '{print $1}' | sort | uniq); do
	echo $NAME
	cd $NAME\_alignments
	for i in $(cat ../alignment.list | awk -v name="$NAME" -F'.' '$1 ~ name {print}'); do
		NAME2=$(echo $i | awk -F';' '{print $2}' | awk -F'.' '{print $1}')
		cd $NAME\_vs_$NAME2\_syri
		echo $i
		echo $NAME2
		cp *at*.pdf $NAME\_vs_$NAME2.syri.pdf
		cd ../
	done
	cd ../
done




