#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | head -n5 | awk '{print $1, $2}' > $NAME.tmp
	cat $NAME.tmp | awk -v name="$NAME" '{print name, $1, $2}' > $NAME.renamed.tmp
	rm $NAME.tmp
done

grep 'Chr1' at*.renamed.tmp > chr1.tmp
grep 'Chr2' at*.renamed.tmp > chr2.tmp
grep 'Chr3' at*.renamed.tmp > chr3.tmp
grep 'Chr4' at*.renamed.tmp > chr4.tmp
grep 'Chr5' at*.renamed.tmp > chr5.tmp

paste chr1.tmp chr2.tmp chr3.tmp chr4.tmp chr5.tmp > chrLengthSummary.4R.tmp
sed -i -e 's/\.renamed\.tmp\:/;/g' chrLengthSummary.4R.tmp
sed -i -e 's/\t/;/g' chrLengthSummary.4R.tmp
sed -i -e 's/ /;/g' chrLengthSummary.4R.tmp

cat chrLengthSummary.4R.tmp | awk -F';' '{print $1, $4, $8, $12, $16, $20}' > chrLengthSummary.4R
sed -i -e 's/ /;/g' chrLengthSummary.4R
sed -i -e 's/at/AT/g' chrLengthSummary.4R

rm *tmp
