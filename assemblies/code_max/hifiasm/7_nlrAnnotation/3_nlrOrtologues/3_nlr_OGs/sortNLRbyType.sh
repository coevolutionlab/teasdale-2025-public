#!/bin/bash

for line in $(cat r_genes.full_set.list.updated20200321.csv | awk -F',' '{print $2}' | sort | uniq); do
	cat r_genes.full_set.list.updated20200321.csv | awk -F',' -v type=$line '$2==type {print}' > $line.type.IDs
done
