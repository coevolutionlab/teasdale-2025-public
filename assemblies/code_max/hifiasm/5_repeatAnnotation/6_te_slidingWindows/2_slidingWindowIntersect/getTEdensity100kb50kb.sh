#!/bin/bash

for i in $(ls at*.edta_clean.filtered.simple.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $i > $NAME.intersect.te_overall.bed
	echo $NAME "processed"
done

for i in $(ls at*.edta_clean.filtered.simple.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$3 == "ClassII_Helitron" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.helitron.bed
	cat $i | awk '$3 == "ClassII_TIR" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.tir.bed
	cat $i | awk '$3 == "ClassI_LINE" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.line.bed
	cat $i | awk '$3 == "ClassI_LTR" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.ltr.bed
	cat $i | awk '$3 == "Other_repeat" {print $1, $4, $5}' | sed 's/ /\t/g' > $NAME.otherRepeat.bed
done


for i in $(ls at*.helitron.bed); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $i > $NAME.helitron.intersect
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $NAME.tir.bed > $NAME.tir.intersect
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $NAME.line.bed > $NAME.line.intersect
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $NAME.ltr.bed > $NAME.ltr.intersect
	bedtools intersect -wa -c -a slidingWindows100kb.step50kb.bed  -b $NAME.otherRepeat.bed > $NAME.otherRepeat.intersect
	echo $NAME "TE types intersected"
done
