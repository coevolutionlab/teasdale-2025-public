#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F"." '{print $1}')
	samtools faidx $i
	mkdir $NAME\_out
	cd $NAME\_out
	cat ../$NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr1/ && $5 == "W" {print $1, $2, $3}' \
	|sed 's/\_RagTag\_RagTag//g' \
	|sed 's/Chr1 /Chr1:/g'\
	|sed 's/ /-/g'  >> chr1.contigs
	cat chr1.contigs | sed -n '1~2p' >> chr1.contigs1
	cat chr1.contigs | sed -n '2~2p' >> chr1.contigs2
	cat ../$NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr2/ && $5 == "W" {print $1, $2, $3}' \
	|sed 's/\_RagTag\_RagTag//g' \
        |sed 's/Chr2 /Chr2:/g'\
        |sed 's/ /-/g'  >> chr2.contigs
	cat chr2.contigs | sed -n '1~2p' >> chr2.contigs1
        cat chr2.contigs | sed -n '2~2p' >> chr2.contigs2
	cat ../$NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr3/ && $5 == "W" {print $1, $2, $3}' \
	|sed 's/\_RagTag\_RagTag//g' \
        |sed 's/Chr3 /Chr3:/g'\
        |sed 's/ /-/g'  >> chr3.contigs
	cat chr3.contigs | sed -n '1~2p' >> chr3.contigs1
        cat chr3.contigs | sed -n '2~2p' >> chr3.contigs2
	cat ../$NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr4/ && $5 == "W" {print $1, $2, $3}' \
	|sed 's/\_RagTag\_RagTag//g' \
        |sed 's/Chr4 /Chr4:/g'\
        |sed 's/ /-/g'  >> chr4.contigs
	cat chr4.contigs | sed -n '1~2p' >> chr4.contigs1
        cat chr4.contigs | sed -n '2~2p' >> chr4.contigs2
	cat ../$NAME.bionano.hifiasm.scaffolds.agp | awk '$1 ~/^Chr5/ && $5 == "W" {print $1, $2, $3}' \
	|sed 's/\_RagTag\_RagTag//g' \
        |sed 's/Chr5 /Chr5:/g'\
        |sed 's/ /-/g'  >> chr5.contigs
	cat chr5.contigs | sed -n '1~2p' >> chr5.contigs1
        cat chr5.contigs | sed -n '2~2p' >> chr5.contigs2
	cat ../$i.fai | awk '$1 ~/^Chr/ {print $1, $2}' >> $NAME.chrLength
	cat chr*.contigs1 > $NAME.contigs1
	cat chr*.contigs2 > $NAME.contigs2
	cd ../
	echo $NAME
done
