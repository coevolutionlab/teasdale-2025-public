#!/bin/bash

for i in $(ls at*final3.aa); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | sed "s/>/>$NAME\_/g" > $NAME.protein.fasta &
done
