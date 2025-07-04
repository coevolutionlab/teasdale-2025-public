#!/bin/bash

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	cat ../$i | grep 'Motif:centromere' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.centromeres 
	cat ../$i | grep 'Motif:telomere' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.telomeres 
	cat ../$i | grep 'Motif:5S_rDNA' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.5S_rDNA 
	cat ../$i | grep 'Motif:45S_rDNA' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.45S_rDNA
	cd ../
done
