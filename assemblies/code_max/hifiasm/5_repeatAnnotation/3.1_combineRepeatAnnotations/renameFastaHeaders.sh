#!/bin/bash

for i in $(ls at*EDTA*gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | sed 's/RagTag\_Rag/RagTag\_RagTag/g' > $NAME.edta.annotation.gff3
done
