#!/bin/bash

for line in $(cat r_genes.full_set.list.updated20200321.csv); do
	NAME=$(echo $line | awk -F',' '{print $1}')
	grep $NAME orthogroups.txt | awk -F';' '{print $1}' >> nlrOGs.tmp
done

cat nlrOGs.tmp | sort | uniq > nlrOGs.list
rm nlrOGs.tmp
