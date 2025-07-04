#!/bin/bash


rm Chr*.summary.mq.4R

for file in $(ls at*.chr.mq.4R); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	for chr in $(cat chr.names); do
		grep $chr $file | awk -v var=$NAME '{print var";"$1}' | awk -F';' '{print $1, $2, $4, $5, $6}' | sed 's/ /;/g' | sed 's/at/AT/g' >> $chr.summary.mq.4R
	done
done




