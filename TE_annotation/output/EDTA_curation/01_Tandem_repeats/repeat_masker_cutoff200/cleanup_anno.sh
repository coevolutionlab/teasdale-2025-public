#!/bin/bash

# This file  retireves only the rDNA annotation, merges annotations up to 100bp apart and filter out leftovers lower than 400 bp.
# lastly, it  changes the output format of the repeatmasker GFF file to use as the final annotation:


cat pangenome.fasta.out.gff | grep rDNA  |
sed 's/Target "Motif:/Classification=/;s/".*$//' |
bedtools  merge -i - -d 100 -c 2,3,9 -o distinct |
awk '{if($3-$2 > 400) print $0 }' |
awk 'BEGIN{FS=OFS="\t"}{print $1,$4,$5,$2+1,$3+1,".",".",".","ID=rDNA_"NR";$6;Sequence_ontology=SO:0000657;Length="$3-$2}'  > pangenome_rDNA_annotation.gff3 ;

