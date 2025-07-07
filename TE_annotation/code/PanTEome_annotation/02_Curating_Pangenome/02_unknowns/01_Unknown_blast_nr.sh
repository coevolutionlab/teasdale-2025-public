#!/usr/bin/env bash

# This script blasts the consensi unknown of the pangenome vs the FEB 2020 blast db.

blast_db="/ebio/abt6_projects9/abt6_databases/db/blast_nt_JUN2022/nt"
EDTA_TElib="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.fa"

mkdir -p TE_annotation/output/02_Curating_Unknowns/blast/
cd TE_annotation/output/02_Curating_Unknowns/blast/

# Retrieve Unknown models.
seqkit grep -nrp "Unknown" $EDTA_TElib > Unknown_TEmodels.fa
grep "^>" Unknown_TEmodels.fa > Unknown_TEmodels_list.txt

# MAIN
blastn -task blastn \
       -db ${blast_db} \
       -query Unknown_TEmodels.fa \
       -out Unknown_TEmodels.blast.out \
       -num_threads   64 \
       -outfmt '6 qseqid qlen sseqid slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs stitle salltitles'

# Filter output:
cat Unknown_TEmodels.blast.out |
grep -v "^#" |
grep -vi "scaffold" |
grep -vi "assembly"  |
grep -vi "chromosome" |
awk 'BEGIN{FS=OFS="\t"} {if($5 > 80 ) ; print $0}' > Unknown_TEmodels.blast.out.clean

# Mot of the Unknown models have matches with predicted proteins.
