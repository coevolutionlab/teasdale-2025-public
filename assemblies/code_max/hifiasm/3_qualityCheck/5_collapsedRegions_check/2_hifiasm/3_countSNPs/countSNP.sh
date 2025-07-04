#!/bin/bash


for i in $(ls at*.GT.FORMAT); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	PLACED=$(cat $i | awk '$1 ~/^Chr/'| wc -l)
	UNPLACED=$(cat $i | awk '$1 !~/^Chr/'| wc -l)
	TOTAL=$(cat $i | wc -l)
	echo $NAME $TOTAL $PLACED $UNPLACED
done

