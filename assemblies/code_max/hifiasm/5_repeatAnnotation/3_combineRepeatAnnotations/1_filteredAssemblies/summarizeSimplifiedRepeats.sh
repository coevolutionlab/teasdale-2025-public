#!/bin/bash

for i in $(ls at*edta_clean.filtered.simple.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TIR=$(grep "ClassII_TIR" $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	LTR=$(grep "ClassI_LTR" $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	OTHER=$(grep "Other_repeat" $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	HELI=$(grep "ClassII_Helitron" $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	LINE=$(grep "ClassI_LINE" $i | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	CLASS_II=$(($TIR + $HELI))
	CLASS_I=$(($LTR + $LINE))
	echo $NAME $TIR $LTR $OTHER $HELI $LINE $CLASS_I $CLASS_II
done


