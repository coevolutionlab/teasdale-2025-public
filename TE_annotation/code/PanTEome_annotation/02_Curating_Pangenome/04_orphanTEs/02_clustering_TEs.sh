#!/usr/bin/env bash

# Variables
cdhit_formatter="TE_annotation/code/format_cdhit_clusterout.py"
pangenome_GFF="TE_annotation/output/EDTA_curation/04_orphanTEs/01_blast_lib/Orphans_TEanno_01_full.gff3"
pangenome_intact_GFF="TE_annotation/output/EDTA_curation/04_orphanTEs/01_blast_lib/Orphans_TEintacts_01_full.gff3"
pangenome="TE_annotation/output/EDTA/pangenome.fasta"
pangenome_TElib="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.fa"
pangenome_TElib_novel="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.novel.fa"

# This file extract structurally intact TEs  annotated as solo and tried to cluster them together.

# Retrieve the fasta sequdences of the orphan intacts.
cp ../01_blast_lib/orphan_intacts.fasta .

# Use  cd-hit to cluster intacts into families base on 80% sim threshold::
cd-hit -i orphan_intacts.fasta -o orphan_clusters.fasta -c 0.8 -n 4 -M 20000 -d 0 -T 64

# Format clusters.fasta.clstr file:
python ${cdhit_formatter} clusters.fasta.clstr   |
sed 's/ /_/;s/... at /\t/;s/... \*/\tRepresentative/;s/, /\t/' > clusters.fasta.clstr.clean

# Retieve clusters with more than 1 item in them and add a second column with the new family name:
cut -f1 clusters.fasta.clstr.clean | sort | uniq -c  |
awk -v counter=1 '{ if ($1 > 1) print $2 "\tName=TE_cluster_" counter++ }' > Cluster_list.txt

# Associate this file with the clusters.fasta.clstr.clean
awk 'BEGIN{FS=OFS="\t"} NR==FNR {h[$1] = $2; next} {if(h[$1]) print $4,h[$1]}'  Cluster_list.txt clusters.fasta.clstr.clean |
sed 's/;name=.*\t/\t/;s/>id=te/ID=TE/;s/id=repeat_region/ID=repeat_region/' > solo_clustered_family_names.txt

# Sustitute the family names of the TEs in the pangenome annotation:
cat ${pangenome_GFF}  |  sed 's/;Name/\tName/;s/;Classification=/\tClassification=/' |
awk 'BEGIN{FS=OFS="\t"} {print $9,$0}' >  temp_anno
# Stitch the new family names:
awk 'BEGIN{FS=OFS="\t"} NR==FNR {h[$1] = $2; next} {if (/##/) print $2 ;
else if(h[$1]) print $2,$3,$4,$5,$6,$7,$8,$9,$10";"h[$1]";"$12 ;
else print $2,$3,$4,$5,$6,$7,$8,$9,$10";"$11";"$12}' solo_clustered_family_names.txt temp_anno > Orphans_TEanno_02_cdhit.gff3
rm temp_anno

# Same process to intact  annotation:
cat ${pangenome_intact_GFF}   |  sed 's/;Name/\tName/;s/;Classification=/\tClassification=/' |
awk 'BEGIN{FS=OFS="\t"} {print $9,$0}' >  temp_anno
awk 'BEGIN{FS=OFS="\t"} NR==FNR {h[$1] = $2; next} {if (/##/) print $2 ;
else if(h[$1]) print $2,$3,$4,$5,$6,$7,$8,$9,$10";"h[$1]";"$12 ;
else print $2,$3,$4,$5,$6,$7,$8,$9,$10";"$11";"$12}' solo_clustered_family_names.txt temp_anno > Orphans_TEintacts_02_cdhit.gff3
rm temp_anno

# Add those TEmodels from CDhit to the final pangenomeTElib.fa file.

# Function to parse TE models with new name and classification
make_TEmodel() {
        #IO
        input_sequence=$1
        TE_annotation=$2

        cluster_TEfam_name=$(grep -w "$input_sequence" clusters.fasta.clstr.clean | grep Representative | awk '{print $1}' | sed 's/>//')

        name=$(grep -w "$input_sequence" clusters.fasta.clstr.clean | grep Representative | awk '{print $4}' | sed 's/>//')

        class=$(grep -iw "$name" "$TE_annotation" | cut -f9 | cut -f3 -d ';' | sed 's/Classification=/#/')

        TE_fasta=$(seqkit grep --quiet -nip "$name" orphan_intacts.fasta)

        # Get name of the cluster for fasta seq:
        name_clust=$(echo "$cluster_TEfam_name" | cut -f2 | sed 's/Name=//')
        name_clust=$(echo "${name_clust}${class}")
        echo "$TE_fasta" | sed "s|>.*|>${name_clust}|"
}
export -f make_TEmodel

# Make a llist of clusters to process :
cat Cluster_list.txt  | cut -f1 | sort | uniq > list2proc.txt
# Run in parallel
parallel --jobs 24 -a list2proc.txt "make_TEmodel {} ${pangenome_GFF}" > new_TE_models.fasta


# Join these new TEmodels to the pangenomeTElib created by EDTA

cp Orphans_TEanno_02_cdhit.gff3 ../
cp Orphans_TEintacts_02_cdhit.gff3 ../
cat ${pangenome_TElib} new_TE_models.fasta > ../pangenome.TElib.newTEfams.fa
cat ${pangenome_TElib_novel} new_TE_models.fasta > ../pangenome.TElib.novel.newTEfams.fa

echo "DONE!"
