#!/bin/bash

echo "genotype;centromereTotal;centromereUnplaced;centromerePlaced;Chr1;Chr2;Chr3;Chr4;Chr5" > centromereSummary.4R

for i in $(ls at*.scaffolds.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cenTotal=$(cat $i | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenPlaced=$(cat $i | awk '$1 ~/^Chr/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenChr1=$(cat $i | awk '$1 ~/^Chr1/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenChr2=$(cat $i | awk '$1 ~/^Chr2/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenChr3=$(cat $i | awk '$1 ~/^Chr3/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenChr4=$(cat $i | awk '$1 ~/^Chr4/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenChr5=$(cat $i | awk '$1 ~/^Chr5/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	cenUnplaced=$(cat $i | awk '$1 !~ /^Chr/' | grep 'Motif:centromere' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	echo $NAME $cenTotal $cenUnplaced $cenPlaced $cenChr1 $cenChr2 $cenChr3 $cenChr4 $cenChr5
	echo $NAME $cenTotal $cenUnplaced $cenPlaced $cenChr1 $cenChr2 $cenChr3 $cenChr4 $cenChr5 >> centromereSummary.4R
done

sed -i -e 's/ /;/g' centromereSummary.4R

echo "done"


echo "genotype;5S_rDNA_total;5S_rDNA_unplaced;5S_rDNA_placed;5S_rDNA_chr1;5S_rDNA_chr2;5S_rDNA_chr3;5S_rDNA_chr4;5S_rDNA_chr5" > 5S_rDNA_summary.4R

for i in $(ls at*.scaffolds.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	rDNA_5S_total=$(cat $i | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_chr1=$(cat $i | awk '$1 ~/Chr1/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_chr2=$(cat $i | awk '$1 ~/Chr2/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_chr3=$(cat $i | awk '$1 ~/Chr3/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_chr4=$(cat $i | awk '$1 ~/Chr4/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_chr5=$(cat $i | awk '$1 ~/Chr5/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_placed=$(cat $i | awk '$1 ~/Chr/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	rDNA_5S_unplaced=$(cat $i | awk '$1 !~ /Chr/' | grep 'Motif:5S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
	echo $NAME $rDNA_5S_total $rDNA_5S_unplaced $rDNA_5S_placed $rDNA_5S_chr1 $rDNA_5S_chr2 $rDNA_5S_chr3 $rDNA_5S_chr4 $rDNA_5S_chr5
	echo $NAME $rDNA_5S_total $rDNA_5S_unplaced $rDNA_5S_placed $rDNA_5S_chr1 $rDNA_5S_chr2 $rDNA_5S_chr3 $rDNA_5S_chr4 $rDNA_5S_chr5 >> 5S_rDNA_summary.4R
done

sed -i -e 's/ /;/g' 5S_rDNA_summary.4R
