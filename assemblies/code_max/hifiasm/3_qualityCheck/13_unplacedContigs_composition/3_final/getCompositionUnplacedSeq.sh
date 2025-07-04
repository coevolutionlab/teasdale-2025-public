#!bin/bash

for i in $(ls at*.TEsUnplacedContigs.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print ($5-$4)}' | awk -v name="$NAME" '{sum+=$1} END {print name, "transposable_elements", sum}' > $NAME.results
	cat $NAME.chrM.chrC.final.gff | awk '$3 == "mitochondria" {print ($5-$4)}' | awk -v name="$NAME" '{sum+=$1} END {print name, "mitochondria", sum}' >> $NAME.results
	cat $NAME.chrM.chrC.final.gff | awk '$3 == "chloroplast" {print ($5-$4)}' | awk -v name="$NAME" '{sum+=$1} END {print name, "chloroplast", sum}' >> $NAME.results
	grep -w '45S_rDNA' $NAME.repeatsUnplacedContigs.gff | awk '{print ($5-$4)}' | awk -v name="$NAME" '{sum+=$1} END {print name, "45S_rDNA", sum}' >> $NAME.results
	grep -w '5S_rDNA' $NAME.repeatsUnplacedContigs.gff | awk '{print ($5-$4)}' | awk -v name="$NAME" '{sum+=$1} END {print name, "5S_rDNA", sum}' >> $NAME.results
	NAME2=$(echo $i | awk -F'.' '{print $1}' | sed 's/at/AT/g')
	UNPLACED=$(grep "$NAME2" placedVsUnplacedLength.4R  | awk -F';' '{print $4}')
	KNOWN=$(cat $NAME.results | awk '{sum+=$3} END {print sum}')
	echo $NAME $UNPLACED $KNOWN > $NAME.known
done
