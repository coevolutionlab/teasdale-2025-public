#!/bin/bash

echo "genotype;centromereTotal;centromereUnplaced;centromerePlaced;Chr1;Chr2;Chr3;Chr4;Chr5" > centromereSummary.4R


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
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
	echo $NAME $cenTotal >> cenTotal.tmp
	echo $cenUnplaced >> cenUnplaced.tmp
	echo $cenPlaced >> cenPlaced.tmp
	echo $cenChr1 >> cen1Placed.tmp
	echo $cenChr2 >> cen2Placed.tmp
	echo $cenChr3 >> cen3Placed.tmp
	echo $cenChr4 >> cen4Placed.tmp
	echo $cenChr5 >> cen5Placed.tmp
done

paste cenTotal.tmp cenUnplaced.tmp cenPlaced.tmp cen1Placed.tmp cen2Placed.tmp cen3Placed.tmp cen4Placed.tmp cen5Placed.tmp > centromere.summary.final.4R
sed -i -e 's/\t/;/g' centromere.summary.final.4R
sed -i -e 's/ /;/g' centromere.summary.final.4R
sed -i '1i\accession;total;unplaced;placed;chr1;chr2;chr3;chr4;chr5' centromere.summary.final.4R
rm cenTotal.tmp cenUnplaced.tmp cenPlaced.tmp cen1Placed.tmp cen2Placed.tmp cen3Placed.tmp cen4Placed.tmp cen5Placed.tmp
sed -i -e 's/at/AT/g' centromere.summary.final.4R



sed -i -e 's/ /;/g' centromereSummary.4R


echo "genotype;5S_rDNA_total;5S_rDNA_unplaced;5S_rDNA_placed;5S_rDNA_chr1;5S_rDNA_chr2;5S_rDNA_chr3;5S_rDNA_chr4;5S_rDNA_chr5" > 5S_rDNA_summary.4R

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
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
	echo $NAME $rDNA_5S_total >> 5S_total.tmp
	echo $rDNA_5S_unplaced >> 5S_unplaced.tmp
	echo $rDNA_5S_placed >> 5S_placed.tmp
	echo $rDNA_5S_chr1 >> 5S_chr1.tmp
	echo $rDNA_5S_chr2 >> 5S_chr2.tmp
	echo $rDNA_5S_chr3 >> 5S_chr3.tmp
	echo $rDNA_5S_chr4 >> 5S_chr4.tmp
	echo $rDNA_5S_chr5 >> 5S_chr5.tmp
done

paste 5S_total.tmp 5S_unplaced.tmp 5S_placed.tmp 5S_chr1.tmp 5S_chr2.tmp 5S_chr3.tmp 5S_chr4.tmp 5S_chr5.tmp | sed 's/\t/;/g' > 5S_rDNA_summary.4R
sed -i -e 's/ /;/g' 5S_rDNA_summary.4R
rm 5S_total.tmp 5S_unplaced.tmp 5S_placed.tmp 5S_chr1.tmp 5S_chr2.tmp 5S_chr3.tmp 5S_chr4.tmp 5S_chr5.tmp

sed -i -e 's/ /;/g' 5S_rDNA_summary.4R
sed -i '1i\accession;total;unplaced;placed;chr1;chr2;chr3;chr4;chr5' 5S_rDNA_summary.4R
sed -i -e 's/at/AT/g' 5S_rDNA_summary.4R



echo "genotype;total;unplaced;placed;chr1;chr2;chr3;chr4;chr5" > 45S_rDNA_summary.4R

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        rDNA_45S_total=$(cat $i | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_chr1=$(cat $i | awk '$1 ~/Chr1/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_chr2=$(cat $i | awk '$1 ~/Chr2/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_chr3=$(cat $i | awk '$1 ~/Chr3/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_chr4=$(cat $i | awk '$1 ~/Chr4/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_chr5=$(cat $i | awk '$1 ~/Chr5/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_placed=$(cat $i | awk '$1 ~/Chr/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        rDNA_45S_unplaced=$(cat $i | awk '$1 !~ /Chr/' | grep 'Motif:45S_rDNA' | awk '{print($5-$4)}' | awk '{s+=$1}END{print s}')
        echo $NAME $rDNA_45S_total $rDNA_45S_unplaced $rDNA_45S_placed $rDNA_45S_chr1 $rDNA_45S_chr2 $rDNA_45S_chr3 $rDNA_45S_chr4 $rDNA_45S_chr5 >> 45S_rDNA_summary.4R
	echo $NAME $rDNA_45S_total >> 45S_total.tmp
        echo $rDNA_45S_unplaced >> 45S_unplaced.tmp
        echo $rDNA_45S_placed >> 45S_placed.tmp
        echo $rDNA_45S_chr1 >> 45S_chr1.tmp
        echo $rDNA_45S_chr2 >> 45S_chr2.tmp
        echo $rDNA_45S_chr3 >> 45S_chr3.tmp
        echo $rDNA_45S_chr4 >> 45S_chr4.tmp
        echo $rDNA_45S_chr5 >> 45S_chr5.tmp
done


paste 45S_total.tmp 45S_unplaced.tmp 45S_placed.tmp 45S_chr1.tmp 45S_chr2.tmp 45S_chr3.tmp 45S_chr4.tmp 45S_chr5.tmp | sed 's/\t/;/g' >  45S_rDNA_summary.4R
rm 45S_total.tmp 45S_unplaced.tmp 45S_placed.tmp 45S_chr1.tmp 45S_chr2.tmp 45S_chr3.tmp 45S_chr4.tmp 45S_chr5.tmp

sed -i -e 's/ /;/g' 45S_rDNA_summary.4R
sed -i '1i\accession;total;unplaced;placed;chr1;chr2;chr3;chr4;chr5' 45S_rDNA_summary.4R
sed -i -e 's/at/AT/g' 45S_rDNA_summary.4R
