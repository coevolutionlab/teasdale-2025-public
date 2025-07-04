#!/bin/bash

for i in $(ls at*protein.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | awk '{print $1, $2}' > $NAME.protein.length &
	echo "all" > $NAME.allGenes.length
	seqtk comp $i | awk '{print $2}' >> $NAME.allGenes.length &
done
