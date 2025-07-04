#!/bin/bash

for i in $(ls at*edta_clean.filtered.simple.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for line in $(cat $i | awk '{print $3}' | sort | uniq); do
		grep "$line" $i > $NAME.$line.tmp
		echo $NAME > $NAME.$line.length
		cat $NAME.$line.tmp | awk -v name="$NAME" '{print ($5-$4)}' >> $NAME.$line.length
		rm $NAME.$line.tmp
	done
	echo $NAME
done

for i in $(ls at*edta_clean.filtered.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME > $NAME.helitron.length
	echo $NAME > $NAME.Gypsy_LTR_retrotransposon.length
	echo $NAME > $NAME.Copia_LTR_retrotransposon.length
        cat $i | awk '$3 == "helitron" {print ($5-$4)}' >> $NAME.helitron.length
        cat $i | awk '$3 == "Gypsy_LTR_retrotransposon" {print ($5-$4)}' >> $NAME.Gypsy_LTR_retrotransposon.length
        cat $i | awk '$3 == "Copia_LTR_retrotransposon" {print ($5-$4)}' >> $NAME.Copia_LTR_retrotransposon.length
done

paste at*.helitron.length | sed 's/\t/;/g' > helitron.length.4R
paste at*.Gypsy_LTR_retrotransposon.length | sed 's/\t/;/g' > gypsy_LTR_retrotransposon.length.4R
paste at*.Copia_LTR_retrotransposon.length | sed 's/\t/;/g' > copia_LTR_retrotransposon.length.4R
