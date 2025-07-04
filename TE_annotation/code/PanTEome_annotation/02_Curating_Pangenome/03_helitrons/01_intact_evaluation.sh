#!/usr/bin/env bash

#Files
pangenome_fasta="TE_annotation/output/EDTA/pangenome.fasta"
pangenome_fai="TE_annotation/output/EDTA/pangenome.fasta.fai"
pangenome_intact_GFF="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.intact.gff3"
pangenome_GFF="TE_annotation/output/EDTA_curation/02_unknowns/pangenome.fasta.mod.EDTA.TEanno.sat.clean.no_unknowns.gff3"

# Prepare dirs
mkdir -p TE_annotation/output/EDTA_curation/03_denovo_Helitrons/01_intact_eval
cd TE_annotation/output/EDTA_curation/03_denovo_Helitrons/01_intact_eval

# Get helitron de novo families:
cat $pangenome_GFF  | grep "DNA/Helitron" | cut -f9 | cut -f2 -d ';' | grep -v AT  | sort  | uniq > Helitron_families.tsv
# get the number of families that have a intact helitron and the numberof intact copies:
cat $pangenome_intact_GFF  | grep Helitron | cut -f9 | cut -f2 -d ';' | sort | uniq -c | awk '{print $2"\t"$1}' > list_intact_helitron_family_members.tsv

# Use  awk to create a file where  the first column is the family name and the second column is the number of intact copies in that family:
awk 'NR==FNR {h[$1] = $0; next} {print $1,h[$1]}'  list_intact_helitron_family_members.tsv  Helitron_families.tsv  |
tr '\s' '\t' | awk '{if(NF==1) print $1"\t0" ; else print $1"\t"$3}' |
sed 's/\t/\t;TEfam_intacts=/' > TEFam_intact_memebers.tsv


# Associate this file back with the original annotation:
cat $pangenome_GFF | awk '{print $9}' | sed 's/^.*Name/Name/;s/;Class.*$//' | paste $pangenome_GFF -  > tmp
awk 'NR==FNR{ seen[$1]=$2; next } { print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9""seen[$10] }'  TEFam_intact_memebers.tsv tmp |
sort -k1,1V -k4,4n -k5,5n > helitron_01_TEannofull_intact_info.gff3
rm tmp

# Associate this file back with the original intact annotation:
cat $pangenome_intact_GFF | awk '{print $9}' | sed 's/^.*Name/Name/;s/;Class.*$//' | paste $pangenome_intact_GFF -  > tmp
awk 'NR==FNR{ seen[$1]=$2; next } { print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9""seen[$10] }'  TEFam_intact_memebers.tsv tmp |
sort -k1,1V -k4,4n -k5,5n > helitron_01_TEannointacts_intact_info.gff3
rm tmp

# Move final  files to  upper directory
cp helitron_01_TEannofull_intact_info.gff3 ../
cp helitron_01_TEannointacts_intact_info.gff3 ../
echo "DONE!"
