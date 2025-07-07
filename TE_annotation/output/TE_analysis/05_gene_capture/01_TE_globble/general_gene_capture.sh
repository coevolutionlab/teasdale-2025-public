#!/usr/bin/env bash

usage() { echo "$0 usage:
Capture of gene fragments by TEs and formation of chimeric transcripts.
This script aims to capture gene fragements or even complete genes that lie within 2 annotates TEs of the same family. " && grep " .)\ #" $0; exit 0; }

[ $# -eq 0 ] && usage

while getopts ":h:s:" arg; do
  case $arg in
    s) # desired max size for merging TE annotations of the same family. 
      max_size=${OPTARG}
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
    ~
done



# Input vars:
gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/00_gene_annotation/ALL_ACCESSIONS.hodgepodgemerged.sorted.gff3"
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
threads=48

### Base name
file_name_gene=$(basename "$gene_anno")
file_name_TE=$(basename "$gene_anno")

### Remove the file extension using parameter expansion
name_geneanno="${file_name_gene%.*}"
name_TEanno="${file_name_TE%.*}"

### Get all the TE familiy names:
grep -v "^#" ${TE_anno} | grep -v "Parent" | cut -f9 | cut -f2 -d ';' | sed 's/#.*$//' | sort | uniq > ${name_TEanno}_TE_Families.txt

### Function to run in parallel
extract_n_merge_by_size() {
    # Input
    fam="$1" ;
    merge_size="$2" ;
    fam_name=$(echo $fam | sed 's/Name=//') ;
    TEanno="$3" ;
    name_prefix="$4" ; 

    # Create a temporary file to store the filtered bed entries
    temp_file_bed=$(mktemp)

    # Corrected variable name 'fam_name' used for grep
    grep "$fam_name" "$TEanno" |
    cut -f1 -d ';' - > "$temp_file_bed"

    bedtools merge -d ${merge_size} -i "$temp_file_bed" -c 9 -o collapse |
    awk -v fam="$fam_name" 'BEGIN {OFS=FS="\t"} {print $0";Name="fam}' > "${name_prefix}_${fam_name}_merged.fam.bed"

    # Clean up the temporary file
    rm "$temp_file_bed"
}
### export
export -f extract_n_merge_by_size

####### MAIN ########

# Get all the TE familiy names:
grep -v "^#"  ${TE_anno} |  grep -v "Parent" | cut -f9 | cut -f2 -d ';' | sed 's/#.*$//' | sort | uniq > TE_Families.txt

## run in parallel

parallel -j ${threads} extract_n_merge_by_size {} ${max_size} ${TE_anno} "merged_max_size_${max_size}bp_" < TE_Families.txt

dirname="$(date +'%Y%m%d%H%M%S')_main_${max_size}bp_maxsize"

mkdir -p ${dirname}

mv  merged_max_size_${max_size}bp_*_merged.fam.bed ${dirname}

cat ${dirname}/*.bed  > merged_max_size_${max_size}bp_all.bed

awk '{if($3 == "gene") print $0 }' ${gene_anno} | bedtools  intersect  -a merged_max_size_${max_size}bp_all.bed  -b - -F 1  -wo > merged_max_size_${max_size}bp_all_catched_whole.tsv

