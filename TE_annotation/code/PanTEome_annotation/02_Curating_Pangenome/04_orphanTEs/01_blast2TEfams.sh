#!/usr/bin/env bash

# Here we are going to blast any of the solo TEs present in the genome against
# the TE library we created in the first place.

# Create the path
mkdir -p /TE_annotation/output/EDTA_curation/04_orphanTEs/01_blast_lib
cd TE_annotation/output/EDTA_curation/04_orphanTEs/01_blast_lib

# Paths
pangenome_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_03_TEannointacts_intact_domain_info_EAov_EAlowc.gff3"
pangenome_intact_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_03_TEannointacts_intact_domain_info_EAov.gff3"
pangenome="TE_annotation/output/EDTA/pangenome.fasta"
pangenome_TElib="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.fa"

# Get the fasta sequdences of the orphan intacts.
grep -v "Parent="  ${pangenome_GFF}   |
awk 'BEGIN{FS=OFS="\t"} {print $1,$4,$5,$9}' |
sed 's/Cla.*$//' |
grep "Name=at" |
bedtools  getfasta -name -fi ${pangenome} -bed - |
sed 's/;Name=.*$//' > solo_intact_pangenome.fasta


# Create blast DB:


makeblastdb  -in $pangenome_TElib   -parse_seqids -dbtype nucl -out pangenome.fasta.mod.EDTA.TElib

# MAIN
blastn -task blastn \
       -db pangenome.fasta.mod.EDTA.TElib \
       -query solo_intact_pangenome.fasta\
       -out solo_intact_pangenome.blast.out \
       -num_threads   64 \
      -outfmt '6 qseqid qlen sseqid slen pident qcovs qcovhsp length qstart qend sstart send evalue bitscore'
# Filter BLAST hits based on 80/80/80 rule
awk -F '\t' '{ if ($5 >= 80 && $6 >= 80 && $8 >= 80) print $0 }' solo_intact_pangenome.blast.out > solo_intact_pangenome.blast.out.filtered
# Sort the BLAST output by query ID and bitscore in descending order
sort -k1,1 -k14,14nr solo_intact_pangenome.blast.out.filtered > solo_intact_pangenome.blast.out.filtered.sorted

# Function to process a single query ID and get the best hit (it will be first
# because the file  is sorted by ID and bitscore)
process_query() {
    query_id="$1"
    query_hits=$(grep -w "$query_id" solo_intact_pangenome.blast.out.filtered.sorted)

    best_hit=$(echo "$query_hits" | head -1)

    echo "$best_hit"
}

export -f process_query

query_ids=$(cut -f1 solo_intact_pangenome.blast.out.filtered.sorted | sort | uniq)

# Use GNU Parallel to process the query IDs in parallel
parallel -j 64 process_query ::: $query_ids > solo_intact_pangenome.blast.out.filtered.sorted.besthit

# Retrieve the names of those TEs found to be in a TE family:
cut -f1 solo_intact_pangenome.blast.out.filtered.sorted.besthit > found_fam_ID.tsv
# Format the best hit file so we can incorporate to the annotation with its new
# family name classification if it was lacking one.


cat solo_intact_pangenome.blast.out.filtered.sorted.besthit |
cut -f1,3 | awk '{print $1"\tName="$2}' > new_column_parse.tsv

# Sustitute the family names of the TEs in the pangenome annotation:
cat ${pangenome_GFF}  |  sed 's/;Name/\tName/;s/;Classification=/\tClassification=/' |
awk 'BEGIN{FS=OFS="\t"} {print $9,$0}' >  temp_anno

# Stitch the new family names:
awk 'BEGIN{FS=OFS="\t"} NR==FNR {h[$1] = $2; next} {if (/##/) print $2 ;
else if(h[$1]) print $2,$3,$4,$5,$6,$7,$8,$9,$10";"h[$1]";"$12 ;
else print $2,$3,$4,$5,$6,$7,$8,$9,$10";"$11";"$12}' new_column_parse.tsv temp_anno > Orphans_TEanno_01_full.gff3
rm temp_anno

# Intact TE anno
# Sustitute the family names of the TEs in the pangenome annotation:
cat ${pangenome_intact_GFF}  |  sed 's/;Name/\tName/;s/;Classification=/\tClassification=/' |
awk 'BEGIN{FS=OFS="\t"} {print $9,$0}' >  temp_anno

# Stitch the new family names:
awk 'BEGIN{FS=OFS="\t"} NR==FNR {h[$1] = $2; next} {if (/##/) print $2 ;
else if(h[$1]) print $2,$3,$4,$5,$6,$7,$8,$9,$10";"h[$1]";"$12 ;
else print $2,$3,$4,$5,$6,$7,$8,$9,$10";"$11";"$12}' new_column_parse.tsv temp_anno > Orphans_TEintacts_01_full.gff3
rm temp_anno

# The rest of the TEs are still orphan, we are going to try to clsuter them
# into families:
seqkit grep -v -f found_fam_ID.tsv solo_intact_pangenome.fasta >  orphan_intacts.fasta
