#!/bin/bash

for i in $(ls at*.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{if ($3 == "exon" || $3 == "CDS") print $1, $2, $3, $4, $5, $6, $7, $8, "source=T"}'| sed 's/ /\t/g' >> $NAME.liftoff.hints &
done
