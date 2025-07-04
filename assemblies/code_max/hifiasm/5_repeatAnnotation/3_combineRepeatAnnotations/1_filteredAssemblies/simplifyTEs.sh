#!/bin/bash

for i in $(ls at*.edta_clean.filtered.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cp $i $NAME.edta_clean.filtered.simple.gff
	echo "simplifying classII TEs"
	sed -i -e 's/CACTA\_TIR\_transposon/ClassII_TIR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/hAT\_TIR\_transposon/ClassII_TIR/g'  $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/PIF\_Harbinger\_TIR\_transposon/ClassII_TIR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/Tc1\_Mariner\_TIR\_transposon/ClassII_TIR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/Mutator\_TIR\_transposon/ClassII_TIR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/helitron/ClassII_Helitron/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/polinton/ClassII_Helitron/g' $NAME.edta_clean.filtered.simple.gff
	echo "simplifying other repeats"
	sed -i -e 's/target\_site\_duplication/Other_repeat/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/repeat\_region/Other_repeat/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/long\_terminal\_repeat/Other_repeat/g' $NAME.edta_clean.filtered.simple.gff
	echo "simplifying classI TEs"
	sed -i -e 's/Copia\_LTR\_retrotransposon/ClassI_LTR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/Gypsy\_LTR\_retrotransposon/ClassI_LTR/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/LINE\_element/ClassI_LINE/g' $NAME.edta_clean.filtered.simple.gff
	sed -i -e 's/LTR\_retrotransposon/ClassI_LTR/g' $NAME.edta_clean.filtered.simple.gff
	echo $NAME "done"
done


