#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	cat ../$i | grep 'Motif:centromere' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.centromeres 
	cat ../$i | grep 'Motif:telomere' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.telomeres 
	cat ../$i | grep 'Motif:5S_rDNA' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.5S_rDNA 
	cat ../$i | grep 'Motif:45S_rDNA' | awk '$1 ~/^Chr/ {print $1":"$4"-"$5}' > $NAME.45S_rDNA
	cd ../
done

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_out
	cat $NAME.centromeres | sed 's/:/\t/g' | sed 's/-/\t/g' > $NAME.centromere.tmp
	bedtools sort -i $NAME.centromere.tmp > $NAME.centromere.bed
	bedtools merge -d 100000 -i $NAME.centromere.bed > $NAME.centromere.4R.tmp
	cat $NAME.centromere.4R.tmp | awk '{if($3-$2 >= 750000) print}' | sed 's/\_RagTag\_RagTag//g' | awk '{print $1":"$2"-"$3}' > $NAME.centromere.4R
	rm $NAME.centromere.4R.tmp
	rm $NAME.centromere.tmp
	cd ../
done


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_out
        cat $NAME.centromeres | sed 's/:/\t/g' | sed 's/-/\t/g' > $NAME.centromere.tmp
        bedtools sort -i $NAME.centromere.tmp > $NAME.centromere.bed
	bedtools merge -d 100000 -i $NAME.centromere.bed | awk 'OFS="\t" {print $1, $2, $3, "centromere", "acen"}' > $NAME.centromere.4R.tmp
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.centromere.4R.tmp
	cat $NAME.centromere.4R.tmp | awk '{if($3-$2 >= 250000) print}' > $NAME.centromere.4R.tmp2
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.chrLength
	sed -i -e 's/ /\t/g' $NAME.chrLength
	bedtools complement -i $NAME.centromere.4R.tmp2 -g $NAME.chrLength | awk 'OFS="\t" {print $1, $2, $3, "genome", "gpos50"}' > $NAME.centromere.4R.tmp
	cat $NAME.centromere.4R.tmp2 >> $NAME.centromere.4R.tmp
	bedtools sort -i $NAME.centromere.4R.tmp > $NAME.centromere.4R
	sed -i '1 i\chr\tstart\tend\tname\tgieStain' $NAME.centromere.4R
	rm $NAME.centromere.tmp
	rm $NAME.centromere.bed
	rm $NAME.centromere.4R.tmp
	rm $NAME.centromere.4R.tmp2
	cd ../
done


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_out
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.contigs1
	sed -i -e 's/\_RagTag\_RagTag//g' $NAME.contigs2
	cd ../
done
