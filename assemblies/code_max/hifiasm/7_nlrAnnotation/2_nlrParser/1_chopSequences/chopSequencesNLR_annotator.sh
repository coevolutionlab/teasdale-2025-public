#!/bin/bash

CHOPPER="/ebio/abt6_projects7/diffLines_20/code/tools/nlr_annotator/ChopSequence.jar"

for i in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	java -jar $CHOPPER -i $i -o $NAME.chopped.fasta &
done


#java -jar ChopSequence.jar -i <inputsequence.fasta> \
#	-o <outputsequence.fasta> -l <sub-sequence length> \
#	-p <length of overlap>

