#!/bin/bash

PARSER="/ebio/abt6_projects7/diffLines_20/code/tools/nlr_annotator/NLR-Parser.jar"
XML="/ebio/abt6_projects7/diffLines_20/code/tools/nlr_annotator/meme.xml"
MEME="/ebio/abt6/mcollenberg/miniconda3/envs/nlr/bin/mast"

for i in $(ls at*.chopped.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_parserResults
	cd $NAME\_parserResults
	nice java -jar $PARSER -t 5 -y $MEME -x $XML -i ../$i -c $NAME.xml &
	cd ../
done
