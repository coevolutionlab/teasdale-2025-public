#!/bin/bash


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.intact.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print $1, $4, $5}' | sed 's/ /\t/g' | sed 's/RagTag\_Rag/RagTag\_RagTag/g' > $NAME.edta.bed
	cat $NAME.nlr.liftoff.gff | awk '{print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.nlr.bed
	cat $NAME.softmasked.final.gff3 | awk '{print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.gene.bed
	nlr=$(bedtools closest -io -d -a $NAME.nlr.bed -b $NAME.edta.bed | awk '{print $7}' | sort -n | awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}')
	gene=$(bedtools closest -io -d -a $NAME.gene.bed -b $NAME.edta.bed | awk '{print $7}' | sort -n | awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}')
	echo $NAME $nlr $gene
done
