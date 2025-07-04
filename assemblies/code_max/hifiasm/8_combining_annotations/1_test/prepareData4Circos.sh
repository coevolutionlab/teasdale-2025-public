#!/bin/bash

for i in $(ls at*scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | awk '$1 ~/^Chr/ {print $1, "0", $2}' | sed 's/ /\t/g'  > $NAME.genome.index.4circos
done

for i in $(ls at*.genome.index.4circos); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print $1, $3}' | sed 's/ /\t/g' > $NAME.genome.txt
	bedtools makewindows -g $NAME.genome.txt -w 100000 > $NAME.windows.4circos
	rm $NAME.genome.txt
done

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	grep "centromere" $i | awk '$1 ~/^Chr/ {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.centromere.gff
	bedtools intersect -c -a $NAME.windows.4circos -b $NAME.centromere.gff > $NAME.centromere.4circos
	sed -i '1 i\chr\tstart\tend\tvalue1' $NAME.centromere.4circos
	rm $NAME.centromere.gff
done

for i in $(ls at*.edta.cleaned.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 ~/^Chr/ {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.te.bed
	bedtools intersect -c -a $NAME.windows.4circos -b $NAME.te.bed > $NAME.te.4circos
	sed -i '1 i\chr\tstart\tend\tvalue1' $NAME.te.4circos
	rm $NAME.te.bed
done

for i in $(ls at*.softmasked.final.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/ && $1 ~/^Chr/' | awk '$3 == "gene" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.genes.tmp
	bedtools intersect -c -a $NAME.windows.4circos -b $NAME.genes.tmp > $NAME.genes.4circos
	sed -i '1 i\chr\tstart\tend\tvalue1' $NAME.genes.4circos
	rm $NAME.genes.tmp
done

for i in $(ls at*.nlr.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 ~/^Chr/' | grep 'NLR=' | awk '{print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.nlr.tmp
	bedtools intersect -c -a $NAME.windows.4circos -b $NAME.nlr.tmp > $NAME.nlr.4circos
	sed -i '1 i\chr\tstart\tend\tvalue1' $NAME.nlr.4circos
	rm $NAME.nlr.tmp
	sed -i -e 's/\_RagTag\_RagTag//g'  $NAME.*.4circos
done


