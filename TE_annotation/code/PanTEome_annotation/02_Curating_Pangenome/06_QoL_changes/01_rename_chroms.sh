#!/usr/bin/env bash

#This script renames the annotation  to follow up the pansm scheme. 

mkdir -p TE_annotation/output/EDTA_curation/06_QoL/01_rename_chrom/
cd TE_annotation/output/EDTA_curation/06_QoL/01_rename_chrom/

### FULL ANNOTATION
pangenome_fasta="TE_annotation/output/PANGENOME_EDTA/pangenome.fasta"
pangenome_fai="TE_annotation/output/PANGENOME_EDTA/pangenome.fasta.fai"
# GFF files:
pangenome_GFF="TE_annotation/output/EDTA_curation/05_taxonomy/Taxonomic_TEanno_01.gff3"
pangenome_intact_GFF="TE_annotation/output/EDTA_curation/05_taxonomy/Taxonomic_TEintact_01.gff3"

# Fix the naming scheme of the chromosome names:
# Make a dict with old and new names:
declare -A chrom_name_dict=(
["at6137_1"]="at6137_1_chr1"
["at6137_2"]="at6137_1_chr2"
["at6137_3"]="at6137_1_chr3"
["at6137_4"]="at6137_1_chr4"
["at6137_5"]="at6137_1_chr5"
["at6137_ptg81l"]="at6137_9_u81"
["at6923_1"]="at6923_1_chr1"
["at6923_2"]="at6923_1_chr2"
["at6923_3"]="at6923_1_chr3"
["at6923_4"]="at6923_1_chr4"
["at6923_5"]="at6923_1_chr5"
["at6923_ptg94l"]="at6923_9_u94"
["at6923_ptg29l"]="at6923_9_u29"
["at6929_1"]="at6929_1_chr1"
["at6929_2"]="at6929_1_chr2"
["at6929_3"]="at6929_1_chr3"
["at6929_4"]="at6929_1_chr4"
["at6929_5"]="at6929_1_chr5"
["at6929_ptg454l"]="at6929_9_u454"
["at6929_ptg732l"]="at6929_9_u732"
["at6929_ptg745l"]="at6929_9_u745"
["at6929_ptg979l"]="at6929_9_u979"
["at6929_ptg37l"]="at6929_9_u1037"
["at6929_ptg1687l"]="at6929_9_u1687"
["at7143_1"]="at7143_1_chr1"
["at7143_2"]="at7143_1_chr2"
["at7143_3"]="at7143_1_chr3"
["at7143_4"]="at7143_1_chr4"
["at7143_5"]="at7143_1_chr5"
["at7143_ptg29l"]="at7143_9_u29"
["at7143_ptg284l"]="at7143_9_u284"
["at8285_1"]="at8285_1_chr1"
["at8285_2"]="at8285_1_chr2"
["at8285_3"]="at8285_1_chr3"
["at8285_4"]="at8285_1_chr4"
["at8285_5"]="at8285_1_chr5"
["at9104_1"]="at9104_1_chr1"
["at9104_2"]="at9104_1_chr2"
["at9104_3"]="at9104_1_chr3"
["at9104_4"]="at9104_1_chr4"
["at9104_5"]="at9104_1_chr5"
["at9104_ptg52l"]="at9104_9_u52"
["at9336_1"]="at9336_1_chr1"
["at9336_2"]="at9336_1_chr2"
["at9336_3"]="at9336_1_chr3"
["at9336_4"]="at9336_1_chr4"
["at9336_5"]="at9336_1_chr5"
["at9336_ptg62l"]="at9336_9_u62"
["at9336_ptg166l"]="at9336_9_u166"
["at9336_ptg244l"]="at9336_9_u244"
["at9336_ptg45l"]="at9336_9_u45"
["at9336_ptg63l"]="at9336_9_u63"
["at9336_ptg97l"]="at9336_9_u97"
["at9336_ptg114l"]="at9336_9_u114"
["at9336_ptg116l"]="at9336_9_u116"
["at9336_ptg143l"]="at9336_9_u143"
["at9336_ptg153l"]="at9336_9_u153"
["at9336_ptg2l"]="at9336_9_u202"
["at9336_ptg258l"]="at9336_9_u258"
["at9336_ptgl"]="at9336_9_u420"
["at9336_ptg476l"]="at9336_9_u476"
["at9503_1"]="at9503_1_chr1"
["at9503_2"]="at9503_1_chr2"
["at9503_3"]="at9503_1_chr3"
["at9503_4"]="at9503_1_chr4"
["at9503_5"]="at9503_1_chr5"
["at9503_ptgl"]="at9503_9_u50"
["at9503_ptg136l"]="at9503_9_u136"
["at9578_1"]="at9578_1_chr1"
["at9578_2"]="at9578_1_chr2"
["at9578_3"]="at9578_1_chr3"
["at9578_4"]="at9578_1_chr4"
["at9578_5"]="at9578_1_chr5"
["at9578_ptg75l"]="at9578_9_u75"
["at9744_1"]="at9744_1_chr1"
["at9744_2"]="at9744_1_chr2"
["at9744_3"]="at9744_1_chr3"
["at9744_4"]="at9744_1_chr4"
["at9744_5"]="at9744_1_chr5"
["at9744_ptg24l"]="at9744_9_u24"
["at9762_1"]="at9762_1_chr1"
["at9762_2"]="at9762_1_chr2"
["at9762_3"]="at9762_1_chr3"
["at9762_4"]="at9762_1_chr4"
["at9762_5"]="at9762_1_chr5"
["at9762_ptg64l"]="at9762_9_u64"
["at9762_ptg42l"]="at9762_9_u42"
["at9762_ptg135l"]="at9762_9_u135"
["at9806_1"]="at9806_1_chr1"
["at9806_2"]="at9806_1_chr2"
["at9806_3"]="at9806_1_chr3"
["at9806_4"]="at9806_1_chr4"
["at9806_5"]="at9806_1_chr5"
["at9806_ptg28l"]="at9806_9_u28"
["at9806_ptgl"]="at9806_9_u30"
["at9830_1"]="at9830_1_chr1"
["at9830_2"]="at9830_1_chr2"
["at9830_3"]="at9830_1_chr3"
["at9830_4"]="at9830_1_chr4"
["at9830_5"]="at9830_1_chr5"
["at9830_ptg393l"]="at9830_9_u393"
["at9830_ptgl"]="at9830_9_u470"
["at9830_ptg1136l"]="at9830_9_u1136"
["at9847_1"]="at9847_1_chr1"
["at9847_2"]="at9847_1_chr2"
["at9847_3"]="at9847_1_chr3"
["at9847_4"]="at9847_1_chr4"
["at9847_5"]="at9847_1_chr5"
["at9847_ptg875l"]="at9847_9_u875"
["at9852_1"]="at9852_1_chr1"
["at9852_2"]="at9852_1_chr2"
["at9852_3"]="at9852_1_chr3"
["at9852_4"]="at9852_1_chr4"
["at9852_5"]="at9852_1_chr5"
["at9879_1"]="at9879_1_chr1"
["at9879_2"]="at9879_1_chr2"
["at9879_3"]="at9879_1_chr3"
["at9879_4"]="at9879_1_chr4"
["at9879_5"]="at9879_1_chr5"
["at9883_1"]="at9883_1_chr1"
["at9883_2"]="at9883_1_chr2"
["at9883_3"]="at9883_1_chr3"
["at9883_4"]="at9883_1_chr4"
["at9883_5"]="at9883_1_chr5"
["at9883_ptg26l"]="at9883_9_u26"
["at9883_ptg121l"]="at9883_9_u121"
["at9900_1"]="at9900_1_chr1"
["at9900_2"]="at9900_1_chr2"
["at9900_3"]="at9900_1_chr3"
["at9900_4"]="at9900_1_chr4"
["at9900_5"]="at9900_1_chr5"
["at9900_ptg26l"]="at9900_9_u26"
["at9900_ptg177l"]="at9900_9_u177"
["at9900_ptg178l"]="at9900_9_u178"
["at9900_ptg763l"]="at9900_9_u763"
)

# Replace the chromosome names :
# TE anno
# Iterate over each line in the GFF TE full annotation
while IFS= read -r line; do
# Iterate over each key in the dictionary
  for key in "${!chrom_name_dict[@]}"; do
# Replace the old name (key) with the new name (value)
    line=${line//$key/${chrom_name_dict[$key]}}
  done
# Append the modified line to a new file.
  echo "$line" >> pangenome_QoL_01_TEfull.gff3
done < $pangenome_GFF

# TE intact 
# Iterate over each line in the GFF TE intact annotation
while IFS= read -r line; do
# Iterate over each key in the dictionary
  for key in "${!chrom_name_dict[@]}"; do
# Replace the old name (key) with the new name (value)
    line=${line//$key/${chrom_name_dict[$key]}}
  done
# Append the modified line to a new file.
  echo "$line" >> pangenome_QoL_01_TEintacts.gff3
done < $pangenome_intact_GFF

echo "Done!"
