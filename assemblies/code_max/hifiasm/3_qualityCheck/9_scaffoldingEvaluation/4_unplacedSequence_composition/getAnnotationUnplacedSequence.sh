#!/bin/bash


for i in $(ls at*.repeatAnnotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^Chr/ && $2 != "EDTA"' > $NAME.centromere_rDNA.unplacedRepeats.gff
	cat $i | awk '$1 !~/^Chr/ && $2 == "EDTA"' > $NAME.edta.unplacedRepeats.gff
	cat $NAME.centromere_rDNA.unplacedRepeats.gff | grep 'Motif:5S_rDNA' | awk '{print ($5-$4)}' | awk -v name=$NAME '{s+=$1}END{print name,"rDNA_5s",s}' > $NAME.unplacedRepeatLength
	cat $NAME.centromere_rDNA.unplacedRepeats.gff | grep 'Motif:45S_rDNA' | awk '{print ($5-$4)}' | awk -v name=$NAME '{s+=$1}END{print name,"rDNA_45s",s}' >> $NAME.unplacedRepeatLength
	cat $NAME.centromere_rDNA.unplacedRepeats.gff | grep 'Motif:centromere' | awk '{print ($5-$4)}' | awk -v name=$NAME '{s+=$1}END{print name,"centromere",s}' >> $NAME.unplacedRepeatLength
	cat $NAME.edta.unplacedRepeats.gff | awk '{print $3}' | sort | uniq > $NAME.te_types.tmp
	for line in $(cat $NAME.te_types.tmp); do
	#	grep $line $NAME.edta.unplacedRepeats.gff | awk '{print ($5-$4)}' | awk -v name=$NAME -v type=$line '{s+=$1}END{print name, type, s}' >> $NAME.unplacedRepeatLength
		grep $line $NAME.edta.unplacedRepeats.gff | awk '{print ($5-$4)}' | awk -v name=$NAME -v type=$line '{s+=$1}END{print name, type, s}' >> $NAME.unplacedRepeatLength.edta
	done
	cat $NAME.unplacedRepeatLength.edta | awk -v name=$NAME '{s+=$3}END{print name,"te_repeat_edta",s}' >> $NAME.unplacedRepeatLength
	UT=$(seqtk comp $NAME.scaffolds.bionano.hifiasm.final.fasta | awk '$1 !~/^Chr/ {print $2}' | awk -v name=$NAME '{s+=$1}END{print name,"unplacedSeqTotal",s}')
	AUT=$(cat $NAME.unplacedRepeatLength | awk '{s+=$3}END{print s}')
	echo $UT $AUT > $NAME.unplacedTotalAnnotatedTotal.tmp
	cat $NAME.unplacedTotalAnnotatedTotal.tmp | awk -v name=$NAME '{print name,"notAnnotated",($3-$4)}' >> $NAME.unplacedRepeatLength
	rm $NAME.unplacedTotalAnnotatedTotal.tmp
	echo $NAME "done"
done

cat at*.unplacedRepeatLength > summary.unplacedRepeats.4R
sed -i -e 's/ /;/g' summary.unplacedRepeats.4R

