#!/bin/bash

for i in $(ls at*.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME >> $NAME.yield
	seqtk comp $i | awk '{print $2}' >> $NAME.yield &
done
