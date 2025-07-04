#!/bin/bash

for i in $(ls at9104.reads.histo); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	Rscript genomeScope.R $i 21 15000 $NAME\_out 1000 &
done
