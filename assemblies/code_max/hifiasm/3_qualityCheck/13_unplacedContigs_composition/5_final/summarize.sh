#!/bin/bash

echo "genotype transposable_elements 45S_rDNA 5S_rDNA chloroplast mitochondria not_annotated" > finalSummaryUnplacedContigAnnotation.4R

for i in $(ls at*.unplacedContigs.annotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NO=$(cat $i | awk '$1 !~/^Chr/ {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	TE=$(cat $i | awk '$2 == "EDTA" {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	rDNA_45S=$(grep '45S_rDNA' $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	rDNA_5S=$(grep -w '5S_rDNA' $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	CH=$(cat $i | awk '$3 == "chloroplast" {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	MT=$(cat $i | awk '$3 == "mitochondria" {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	echo $NAME "transposable_elements" $TE
	echo $NAME "45S_rDNA" $rDNA_45S
	echo $NAME "5S_rDNA" $rDNA_5S
	echo $NAME "chloroplast" $CH
	echo $NAME "mitochondria" $MT
	NAME2=$(echo $NAME | sed 's/at/AT/g')
	UNKNOWN=$(grep $NAME2 placedVsUnplacedLength.4R | awk -F';' '{print $4}')
	SUM=$((($UNKNOWN - $TE - $rDNA_45S - $rDNA_5S - $CH - $MT)))
	echo $NAME "transposable_elements" $TE > $NAME.results
        echo $NAME "45S_rDNA" $rDNA_45S >> $NAME.results
        echo $NAME "5S_rDNA" $rDNA_5S >> $NAME.results
        echo $NAME "chloroplast" $CH >> $NAME.results
        echo $NAME "mitochondria" $MT >> $NAME.results
	echo $NAME "unknown" $SUM >> $NAME.results
	echo $NAME $TE $rDNA_45S $rDNA_5S $CH $MT $SUM >> finalSummaryUnplacedContigAnnotation.4R
done


sed -i -e 's/ /;/g' finalSummaryUnplacedContigAnnotation.4R
