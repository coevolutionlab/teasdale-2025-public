#!/usr/bin/env bash


pangenome_TEannotation="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/merging_by_fam/pangenome_TEannotation.gff3"
threads=48


# FUNCTION  EXTRACT and merge

# tmp dir creation
mkdir -p  tmp_dir/

# fuction
extract_n_merge() {
    # Input
    fam="$1"
    fam_name=$(echo $fam | sed 's/Name=//')
    TEanno="$2"  # Changed TE_anno to TEanno (consistent variable name)

    # Corrected variable name 'fam_name' used for grep
    grep "$fam_name" "$TEanno" |
    cut -f1 -d ';' - >  tmp_dir/temp_${fam} ;

    bedtools merge -i  tmp_dir/temp_${fam}  -c 9 -o collapse |
    awk -v fam="$fam_name" 'BEGIN {OFS=FS="\t"} {print $0";Name="fam}' > "${fam_name}_merged.fam.bed"

}


export -f extract_n_merge


# Get all the TE familiy names:
grep -v "^#" ${pangenome_TEannotation}  | cut -f9 | cut -f2 -d ';' | sed 's/#.*$//' | sort | uniq > TE_Families.txt


# Run in parallel using 48 cores
parallel -j ${threads} extract_n_merge {} ${pangenome_TEannotation} < TE_Families.txt

mkdir -p ./tmp_beds/
mv *_merged.fam.bed ./tmp_beds/

cat ./tmp_beds/*_merged.fam.bed | sort -k1,1V -k2,2n -k3,3n > final_TE_annotation_merged_fam.bed
