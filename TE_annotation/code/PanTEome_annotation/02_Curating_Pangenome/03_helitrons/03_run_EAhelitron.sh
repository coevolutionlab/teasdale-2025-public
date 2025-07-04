#!/usr/bin/env bash

# # Get the tool: EAhelitrons from github:
# # git clone https://github.com/dontkme/EAHelitron
# I modified the parallel version of EAhelitron as it was not using any argv
# variables (getops was badly constructed). So  the new parallel versiion is
# called EAHelitron_P_mod.

# # Path and tool env
mkdir -p TE_annotation/output/EDTA_curation/03_denovo_Helitrons/03_EAHelitron/run_EAhelitron/
cd TE_annotation/output/EDTA_curation/03_denovo_Helitrons/03_EAHelitron/run_EAhelitron/

EAhelitron="TE_annotation/code/EAHelitron/EAHelitron_P_mod"
pangenome_fasta="TE_annotation/output/EDTA/pangenome.fasta"
pangenome_fai="TE_annotation/output/EDTA/pangenome.fasta.fai"




# # Run EAhelitron in  all the genomes
perl ${EAhelitron} -p 24 pangenome_EAhelitron 20000 ${pangenome_fasta}
# # EAHelitron by default only outputsd in the GFF the 5' and 3' termini. Because of this, I need to  make a bed file out of thei nformation of the fasta header.

cat pangenome_EAhelitron.5.fa | grep "^>" |
cut -f2 -d ' ' | sed 's/:/\t/;s/\.\./\t/' |
awk 'BEGIN{OFS="\t"}{if($3-$2 < 0) print $1,$3,$2 ; else print $0}' > tmp
#Add names:
cat pangenome_EAhelitron.5.fa | grep "^>"  |
cut -f1 -d ' ' | paste tmp - | sed 's/>//' > FULL_LENGTH_HELITRONS.bed
rm tmp

# Get lengths of helitrons and length and gene model information in a tsv table to visualizaiton:

cat FULL_LENGTH_HELITRONS.bed  | sed 's/#/\t/' | sed 's/\(.*\)\./\1\t/' |
awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5,$3-$2}' > EA_helitrons.tsv
#format: Chrom start end accession gene_model length

# copy final files
cp FULL_LENGTH_HELITRONS.bed ../
cp EA_helitrons.tsv ../
