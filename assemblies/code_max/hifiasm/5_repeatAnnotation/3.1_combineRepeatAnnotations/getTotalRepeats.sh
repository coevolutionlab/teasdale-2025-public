#!/bin/bash

for i in $(ls repeatSummary.4R); do
	NAME=$(echo $i | awk -F'.4R' '{print $1}')
	for line in $(cat $i | awk -F';' '{print $1}' | sort | uniq); do
		grep $line $i > $line.$NAME.out.tmp
		cat $line.$NAME.out.tmp | awk -F';' -v type=$NAME -v name=$line '{s+=$3}END{print name,type, s}'
		rm $line.$NAME.out.tmp
	done
done
