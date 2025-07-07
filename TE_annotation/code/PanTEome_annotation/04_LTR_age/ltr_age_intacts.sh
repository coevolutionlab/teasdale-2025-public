#!/bin/bash

# LTR AGE

cd /tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/TE_analisis/ltr_sequences

pangenome="/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/pangenome_onlychrom.fasta"


# Get an ID list for each genome annotation:
 for TEanno in *_TEintact.gff3; do
      name=$(basename $TEanno _TEintact.gff3) ; cat $TEanno  |
      awk 'BEGIN{OFS="\t"}{if($3 ~ /LTR/ && $9 ~ /[r,l]LTR/) print $9}' |
      cut -f2 -d ';' |
      sed 's/Parent=//' | uniq >  ltr_sequences/${name}_ltr_IDs.txt ;
done


cd ltr_sequences/

# Extract fasta files and alignm them using mafft :
for  genome_list in *_ltr_IDs.txt ;
  do gname=$(basename $genome_list _ltr_IDs.txt) ;
  mkdir -p ${gname}_ltrs/ ;
  for ID in $( cat $genome_list) ; do
    grep -w $ID ../${gname}_TEintact.gff3 |
    awk 'BEGIN{OFS="\t"}{if($9 ~ /[r,l]LTR/) print $0}' |
    bedtools getfasta -fi ${pangenome} -bed - |
    mafft --adjustdirection --auto - > ${gname}_ltrs/ltr_${ID}.aln
  done;
done


# Load files in a Rscript to estimate age:

Rscript difflines_ltr_age_stimation.R

