#!/bin/bash

for i in $(ls *.4R); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i  | awk -F';' '$3 == "hifiasm" || $1 ~/^accession/ {print $1, $2}'> $NAME.hifiasm.4R
	sed -i -e 's/ /;/g' $NAME.hifiasm.4R
done
