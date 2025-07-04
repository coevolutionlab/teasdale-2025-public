#!/bin/bash

source activate augustus3.3.3

for i in $(ls at*.softmasked*gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	getAnnoFasta.pl $i &
done
