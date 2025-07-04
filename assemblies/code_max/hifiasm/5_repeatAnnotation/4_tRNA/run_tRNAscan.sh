#!/bin/bash


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do 
	NAME=$(echo $i | awk -F'.' '{print $1}')
	tRNAscan-SE -HQ --detail --thread 12 -p $NAME -f $NAME.tRNA.structure \
	-s $NAME.tRNA.isotype \
	-a $NAME.tRNA.fasta \
	-o $NAME.tRNA.txt \
	$i &
done


#echo "Filtering High Confidence tRNAs..."
#EukHighConfidenceFilter --remove \
#        -i $outputTMP/$ACC.tRNA.txt \
#        -s $outputTMP/$ACC.tRNA.struct \
#        -o $outputTMP -p /$ACC.tRNA

#echo "Re-formatting tRNAscan output to gff3..."
#awk -v OFS='\t' '{
#        if(NR>3) { printf "%s\t%s\t%s\t", $1, "tRNAscan-SE", "tRNA"; 
#                if($4>$3){
#                        print $3, $4, ".", "+", ".", "ID=tRNA_"$2";Repeat_type=tRNA_"$5"_"$6";Length="$4-$3";Isotype="$12";Inf_score="$9";HMM_score="$10";Isotype_score="$13""
#                }
#                else{
#                        print $4, $3 ,".", "-", ".", "ID=tRNA_"$2";Repeat_type=tRNA_"$5"_"$6";Length="$3-$4";Isotype="$12";Inf_score="$9";HMM_score="$10";Isotype_score="$13""
#                }
#        }
#}' $outputTMP/$ACC.tRNA.out > $outputTMP/$ACC.tRNA.gff  

