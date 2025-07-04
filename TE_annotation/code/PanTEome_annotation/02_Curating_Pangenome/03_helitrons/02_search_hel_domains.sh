#!/usr/bin/env bash

# This script uses the output of 01_intact_evaluation.sh file to search for TE
# protein domains containing in the  de novo families using TEsorter and the
# RExDB database.

# Install TE sorter:
# https://github.com/zhangrengang/TEsorter
# conda install -c bioconda tesorter
# We are using the version of TEsorter:
# TEsorter --version
# TEsorter 1.4.6
# And the REXdb database: REXdb_protein_database_viridiplantae_v3.0.hmm


mkdir -p TE_annotation/output/03_denovo_Helitrons/02_search_domains/
cd TE_annotation/output/03_denovo_Helitrons/02_search_domains/

#Files

pangenome_fasta="TE_annotation/output/EDTA/pangenome.fasta"
pangenome_fai="TE_annotation/output/PANGENOME_EDTA/pangenome.fasta.fai"
pangenome_helitron_01_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_01_TEannofull_intact_info.gff3"
pangenome_helitron_01_intacts_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_01_TEannointacts_intact_info.gff3"


# Retrieve fasta sequences of all helitrons
# Carefdul with the bedtools version in use as the flag -name behaviour may
# change between versions : bedtools v2.30.0
cat $pangenome_helitron_01_GFF |
awk 'BEGIN{OFS=FS="\t"}{if ($9 ~ /Classification=.*Helitron/ ) print $1,$4,$5,$9,$5-$4,$7}'  |
bedtools  getfasta -s -name -fi $pangenome_fasta -bed -  |
sed 's/ID=//;s/;Classif.*$//;s/;/_/'  >  all_helitrons.fasta
# Retreive all de  helitron family names :

cat $pangenome_helitron_01_GFF |
awk 'BEGIN{OFS=FS="\t"}{if ($9 ~ /Classification=.*Helitron/ ) print $9}'  |
cut -f2 -d ';' | sed 's/Name=//;s/AT.*_//' | sort | uniq > Helitron_families.tsv


# Run TEsorter
mkdir -p TEsorter_classification/
cd TEsorter_classification/
TEsorter ../all_helitrons.fasta  -db rexdb-plant -p 24
cd ../
# remove to save space
rm all_helitrons.fasta
########

# Because Helitrons tend to adquiere other protein domains from genes and TEs,
# their sequences are pepper with other domains, counfounding the algorithm.
# Thus, we only retrieve those Helitrons with a HEL domain detected.
cat  TEsorter_classification/all_helitrons.fasta.rexdb-plant.cls.tsv |
awk 'BEGIN{OFS=FS="\t"} {if($7 ~ /HEL/) print $1}' > Helitrons_w_doms.tsv

# Count number of Helitron domains per family  in the annotation:
for fam in $(cat Helitron_families.tsv)  ; do
  echo $fam ;
  grep -c "${fam}"  Helitrons_w_doms.tsv ;
done | paste - -  | awk '{if($2 > 0 ) print $0}' > count_Hel_fam.tsv

# Create a new  entry in the Attirbute  GFF of the final annotation.

for fam in $(cat Helitron_families.tsv) ; do
    HEL_found=$(grep -c "${fam}"  Helitrons_w_doms.tsv) ;
    if [ ${HEL_found} -ne 0 ] ;  then
        echo -e "${fam}\t;RXDB_Hel_domain_fam=Yes"
    else
        echo -e "${fam}\t;RXDB_Hel_domain_fam=No"
    fi
done > final_helitron_Helfam.tsv

# Associate this file back with the original annotation:
cat ${pangenome_helitron_01_GFF} | awk '{print $9}' | sed 's/^.*Name=//;s/;Class.*$//' | paste ${pangenome_helitron_01_GFF} -  > tmp
awk 'NR==FNR{ seen[$1]=$2; next } { print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9""seen[$10] }' final_helitron_Helfam.tsv tmp > helitron_02_TEannofull_intact_domain_info.gff3
rm tmp

cat ${pangenome_helitron_01_intacts_GFF} | awk '{print $9}' | sed 's/^.*Name=//;s/;Class.*$//' | paste ${pangenome_helitron_01_intacts_GFF} -  > tmp
awk 'NR==FNR{ seen[$1]=$2; next } { print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9""seen[$10] }' final_helitron_Helfam.tsv tmp > helitron_02_TEannointacts_intact_domain_info.gff3
rm tmp

# Helitrons
cp helitron_02_TEannofull_intact_domain_info.gff3 ../
cp helitron_02_TEannointacts_intact_domain_info.gff3 ../
