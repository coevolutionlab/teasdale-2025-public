#!/bin/bash

for i in $(ls at*.unplacedContigsAnnotation.gff); do
	NO=$(cat $i | awk '$1 !~/^Chr/ {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	echo $i $NO
done
