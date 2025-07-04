#!/bin/bash

echo "annotating chloroplast in:"
for i in $(ls at*.chrC.paf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	awk -v OFS='\t' '{print $1, "Minimap2", $6, $3+=1, $4, ".", $5, ".", "ID="$6"_"NR";Length="$11";percent_identity="$10/$11*100";contigLength:"$2";percentChloroplast:"$11/$2*100}' $NAME.chrC.paf > $NAME.chrC.gff
	sort -k1,1 -k4n $NAME.chrC.gff > $NAME.chrC.sorted.gff
	bedtools merge -i $NAME.chrC.sorted.gff -c 1,9 -o count,collapse > $NAME.chrC.tmp
	echo $NAME "done"
done

echo "annotating mitochondria in:"
for i in $(ls at*.chrM.paf); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
	awk -v OFS='\t' '{print $1, "Minimap2", $6, $3+=1, $4, ".", $5, ".", "ID="$6"_"NR";Length="$11";percent_identity="$10/$11*100";contigLength:"$2";percentMitochrondria:"$11/$2*100}' $NAME.chrM.paf > $NAME.chrM.gff
        sort -k1,1 -k4n $NAME.chrM.gff > $NAME.chrM.sorted.gff
	bedtools merge -i $NAME.chrM.sorted.gff -c 1,9 -o count,collapse > $NAME.chrM.tmp
        echo $NAME "done"
done

for i in $(ls at*chrC.tmp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	awk -v OFS='\t' '{print $1, "minimap2", "chloroplast", $2+=1, $3, ".", "+", ".", "ID=chloroplast_"NR";Length="$3-$2";Merged="$4"", $5 }' $NAME.chrC.tmp > $NAME.chrC.merged.tmp
	cat $NAME.chrC.merged.tmp | sed 's/;/\t/g' | awk 'OFS="\t" {print $1, $2, $3, $4, $5, $6, $7, $8, $9";" $10";"$11";"$14";"$15";"$16}' | awk -F',' 'OFS="\t" {print $1}' > $NAME.chrC.merged.gff
#	rm $i
done

for i in $(ls at*chrC.tmp); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        awk -v OFS='\t' '{print $1, "minimap2", "mitochondria", $2+=1, $3, ".", "+", ".", "ID=mitochondria_"NR";Length="$3-$2";Merged="$4"", $5 }' $NAME.chrM.tmp > $NAME.chrM.merged.tmp
	cat $NAME.chrM.merged.tmp | sed 's/;/\t/g' | awk 'OFS="\t" {print $1, $2, $3, $4, $5, $6, $7, $8, $9";" $10";"$11";"$14";"$15";"$16}' | awk -F',' 'OFS="\t" {print $1}' > $NAME.chrM.merged.gff  
#        rm $i
done

for i in $(ls at*chrC.merged.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -a $NAME.chrC.merged.gff -b $NAME.chrM.merged.gff -wa -wb > $NAME.chrM.chrC.intersect.wab.gff
	bedtools intersect -a $NAME.chrM.merged.gff -b $NAME.chrC.merged.gff -v > $NAME.chrM.intersect.v.gff
	bedtools intersect -a $NAME.chrC.merged.gff -b $NAME.chrM.merged.gff -v > $NAME.chrC.intersect.v.gff
	cat $NAME.*.intersect.v.gff > $NAME.chrM.chrC.final.gff
	rm $NAME.chrC.sorted.gff
	rm $NAME.chrM.sorted.gff
#	rm $NAME.chrC.gff
#	rm $NAME.chrM.gff
#	rm $NAME.chrC.tmp
#	rm $NAME.chrM.tmp
#	rm $NAME.chrC.merged.tmp
#	rm $NAME.chrM.merged.tmp
	rm $NAME.chrC.merged.gff
	rm $NAME.chrM.merged.gff
#	rm $NAME.chrC.intersect.v.gff
#	rm $NAME.chrM.intersect.v.gff
done



#ChrM
#$BEDTOOLS intersect -a  $outputTMP/$ACC.ChrC.merged.gff -b  $outputTMP/$ACC.ChrM.merged.gff -wa -wb > $outputTMP/$ACC.ChrCM.wab.gff
#$BEDTOOLS intersect -a  $outputTMP/$ACC.ChrC.merged.gff -b  $outputTMP/$ACC.ChrM.merged.gff -v > $outputTMP/$ACC.ChrC.v.gff
#$BEDTOOLS intersect -a  $outputTMP/$ACC.ChrM.merged.gff -b  $outputTMP/$ACC.ChrC.merged.gff -v > $outputTMP/$ACC.ChrM.v.gff
#cat $outputTMP/$ACC.ChrC.v.gff $outputTMP/$ACC.ChrM.v.gff $outputTMP/$ACC.ChrCM.uniq.gff \
#rm $outputTMP/$ACC.ChrM.*.gff
