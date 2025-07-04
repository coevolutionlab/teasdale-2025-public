#!/bin/bash

source activate nlr

ANNOTATOR="/ebio/abt6_projects7/diffLines_20/code/tools/nlr_annotator/NLR-Annotator.jar"

for i in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_nlrAnnotatorResults
	cd $NAME\_nlrAnnotatorResults
	java -jar $ANNOTATOR \
	-i ../$NAME.xml \
	-o $NAME.nlr.txt \
	-g $NAME.nlr.gff \
	-b $NAME.nlr.bed \
	-m $NAME.nlr.motifs.bed \
	-a $NAME.nlr.nbarkMotifAlignment.fasta \
	-f ../$NAME.scaffolds.bionano.hifiasm.final.fasta $NAME.nlr.fasta 2500 &
	cd ../
done

