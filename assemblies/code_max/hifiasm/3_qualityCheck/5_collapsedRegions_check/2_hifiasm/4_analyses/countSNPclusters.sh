#!/bin/bash

for i in $(ls at*.snp.summary.final); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | wc -l)
	echo $NAME $NO
done
