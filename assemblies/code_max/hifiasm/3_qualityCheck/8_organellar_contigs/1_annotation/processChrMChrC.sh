#!/bin/bash

#for i in $(ls at*chrM.paf); do
#	NAME=$(echo $i | awk -F'.' '{print $1}')
#	awk -v 'OFS="\t" '{print $1, 

#awk -v OFS='\t' '{print $1, "minimap2", $6, $3+=1, $4, ".", $5, ".", "ID="$6"_"NR";Repeat_type="$6";Length="$11";Coordinates="$8"-"$9";Identity="$10/$11"" }' $outputTMP/$ACC.ChrC.paf > $outputTMP/$ACC.ChrC.gff
#	$outputTMP/$ACC.ChrC.gff \	


for i in $(ls at*chrM.paf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print $1, $2}' | sort | uniq | sed 's/ /;/g'> $NAME.ids
	echo "contig length chrMlength" > $NAME.lengthChrM
	for line in $(cat $NAME.ids); do
		ID=$(echo $line | awk -F';'  '{print $1}')
		ContigLength=$(echo $line | awk -F';' '{print $2}')
		ChrMlength=$(grep $ID $i | awk '{sum+=$11} END {print sum}')
		echo $ID $ContigLength $ChrMlength >> $NAME.lengthChrM
	done
	rm $NAME.ids
done

for i in $(ls at*chrC.paf); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cat $i | awk '{print $1, $2}' | sort | uniq | sed 's/ /;/g'> $NAME.ids
        echo "contig length chrClength" > $NAME.lengthChrC
        for line in $(cat $NAME.ids); do
                ID=$(echo $line | awk -F';'  '{print $1}')
                ContigLength=$(echo $line | awk -F';' '{print $2}')
                ChrClength=$(grep $ID $i | awk '{sum+=$11} END {print sum}')
                echo $ID $ContigLength $ChrClength >> $NAME.lengthChrC
        done
        rm $NAME.ids
done
