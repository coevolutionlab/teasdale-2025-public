#!/bin/bash

for i in $(cat svSummary.4R | awk -F';' '{print $2}' | sort | uniq); do 
	grep $i svSummary.4R | awk -F';' '{print $1, $3}' | sed 's/ /;/' > $i.summary.4R
done

