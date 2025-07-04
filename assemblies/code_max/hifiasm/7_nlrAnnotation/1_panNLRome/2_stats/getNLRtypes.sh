#!/bin/bash

echo "genotype;TNL;NL;CNL;RNL"

echo "TNL" > TNL.summary.tmp
echo "NL" > NL.summary.tmp
echo "CNL" > CNL.summary.tmp
echo "RNL" > RNL.summary.tmp

for i in $(ls at*.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TNL=$(grep 'NLR=TNL' $i | wc -l)
	CNL=$(grep 'NLR=CNL' $i | wc -l)
	NL=$(grep 'NLR=NL' $i | wc -l)
	RNL=$(grep 'NLR=RNL' $i | wc -l)
	echo $NAME $TNL $NL $CNL $RNL | sed 's/ /;/g' | sed 's/at/A/g'
	echo "TNL" $TNL >> TNL.summary.tmp
	echo "NL" $NL >> NL.summary.tmp
	echo "CNL" $CNL >> CNL.summary.tmp
	echo "RNL" $RNL >> RNL.summary.tmp
done 
echo "type;count" > nlrTypeSummary.count.4R
cat *NL.summary.tmp | awk 'NF==2' | sed 's/ /;/g'  >> nlrTypeSummary.count.4R
rm *NL.summary.tmp
