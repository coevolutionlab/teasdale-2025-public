#!/usr/bin/env bash

# Capture of gene fragments by TEs and formation of chimeric transcripts.
# This script aims to capture gene fragements or even complete genes that lie within 2 annotates TEs of the same family. 

# Input vars:
gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final_annotation/latest/ALL_ACCESSIONS.hodgepodgemerged.gff3"
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
threads=48

### Base name
file_name_gene=$(basename "$gene_anno")
file_name_TE=$(basename "$gene_anno")

### Remove the file extension using parameter expansion
name_geneanno="${file_name_gene%.*}"
name_TEanno="${file_name_TE%.*}"

# Statisitcs of the features:
### Gene stats
awk '{if($3 == "gene") print $0 }' ${gene_anno} |
awk '{ difference = $5 - $4; total_difference += difference; sum_of_squares += difference * difference; if (difference > max_difference || NR == 1) { max_difference = difference }; count++ }
END { average = total_difference / count; variance = (sum_of_squares - (total_difference * total_difference / count)) / count; standard_deviation = sqrt(variance) ;
print "Count\t" count ;
print "Average\t"average;
print "Max\t"max_difference;
print "Standard deviation\t"standard_deviation }' > ${name_geneanno}_gene_stats.tsv
### Exon stats
awk '{if($3 == "exon") print $0 }' ${gene_anno} |
awk '{ difference = $5 - $4; total_difference += difference; sum_of_squares += difference * difference; if (difference > max_difference || NR == 1) { max_difference = difference }; count++ }
END { average = total_difference / count; variance = (sum_of_squares - (total_difference * total_difference / count)) / count; standard_deviation = sqrt(variance) ;
print "Count\t" count ;
print "Average\t"average;
print "Max\t"max_difference;
print "Standard deviation\t"standard_deviation }' > ${name_geneanno}_exon_stats.tsv

# Now, create separate TE annotations per each family and merge if they are less than  the maximun  of both the exon and the gene apart

### Get all the TE familiy names: 
grep -v "^#" ${TE_anno} | cut -f9 | cut -f2 -d ';' | sed 's/#.*$//' | sort | uniq > ${name_TEanno}_TE_Families.txt

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

# get gene mean
merge_size_gene=$(cat ${name_geneanno}_gene_stats.tsv | grep Average | cut -f2)
# remove decimals
merge_size_gene=$(printf "%.0f" "$merge_size_gene")

# Get all the TE familiy names:
grep -v "^#"  ${TE_anno} |  cut -f9 | cut -f2 -d ';' | sed 's/#.*$//' | sort | uniq > TE_Families.txt

## run in parallel

parallel -j ${threads} extract_n_merge_by_size {} ${merge_size_gene} ${TE_anno} "exon_mean_size" < TE_Families.txt

mkdir -p tmp_exon_mean_size/
mv  exon_mean_size*_merged.fam.bed tmp_exon_mean_size/

