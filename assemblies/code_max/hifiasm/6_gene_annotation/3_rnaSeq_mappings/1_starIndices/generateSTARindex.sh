#!/bin/bash



for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_starIndex
	cd $NAME\_starIndex
	STAR --runThreadN 10 --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles ../$i &
	cd ../
done


