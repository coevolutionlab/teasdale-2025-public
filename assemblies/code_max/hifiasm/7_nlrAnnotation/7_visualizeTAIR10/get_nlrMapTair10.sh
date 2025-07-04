#!/bin/bash

rm tair10.nlr.map


for line in $(cat tair10.nlr.list); do
	grep $line tair10.gff | awk '{print $1, $4, $5, $3}' >> tair10.nlr.map
done

sed -i -e 's/ /\t/g' tair10.nlr.map
