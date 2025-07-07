#!/usr/bin/env bash
### Create a consensus TE model for each family:

for superfam in  DNA LINE SINE Helitron LTR ; do
	mkdir -p ${superfam}
	awk -v superfam=$superfam '{if($2 ~ superfam) print $1}' TAIR10_Transposable_Elements_classification.tsv > ${superfam}/${superfam}_TEfamilies.tsv ;

	for fam in $(cat  ${superfam}/${superfam}_TEfamilies.tsv) ; do
		seqkit grep -nrp "\|${fam}\|" TAIR10_TE.fas > fam.fa ;
	    mafft --thread 24 fam.fa > aligment.fa ;
		cons -plurality 1 -identity 1 -sequence aligment.fa  -outseq  ${superfam}/${fam}.consensus.fa ;
		rm aligment.fa ;
		rm fam.fa ;
	done
done

