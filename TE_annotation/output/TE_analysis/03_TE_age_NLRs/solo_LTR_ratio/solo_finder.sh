#!/usr/bin/env bash

# Threads to parallelize
threads=48
# Files:
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
TE_anno_intact="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation_intact.gff3"
pangenome="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome.fasta"

########## Parameters to consider a TE a LTR are based on those found in LTR retriever
# solo_finder.pl "https://github.com/oushujun/LTR_retriever/blob/master/bin/solo_finder.pl"

# minlen=80;     # bp, shortest solo LTR length allowed
# mincov=0.8;    # minimum coverage of the library LTR sequence
# maxcov = 1.2;  # maximum coverage
# Aligned sequence requirements:
# Number of residue matches = between 0.8 and 1.2 of the query LTR_length
# Alignment block length = between 0.8 and 1.2 of the query LTR_length


# FUN
retrieve_solo() {
    # Inputs
    local family="$1"
    local TE_anno_intact="$2"
    local TE_anno="$3"
    local pangenome="$4"
    local out_name="$5"

    # Check if required tools are available
    if ! command -v minimap2 &> /dev/null || ! command -v bedtools &> /dev/null; then
        echo "Error: minimap2 and bedtools are required but not found. Please install them."
        return 1
    fi

    # Check if required files exist
    if [ ! -f "$TE_anno_intact" ] || [ ! -f "$TE_anno" ] || [ ! -f "$pangenome" ]; then
        echo "Error: One or more input files not found."
        return 1
    fi

    # Create temporary files
    local temp_fam_fasta=$(mktemp "family.XXXXXXXXXX.fa")
    local temp_paf_file=$(mktemp "family.XXXXXXXXXX.paf")

    # Retrieve the most complete LTR based on the Identity bit
    ID_ltr=$(grep -w "${family}" "${TE_anno_intact}" |
        grep "ID=.LTR" | cut -f9 |
        tr ';' '\t' | sort -rV -k6,6 |
        head -n1 | cut -f1)

    # Retrieve its sequence and store it
    grep -w "$ID_ltr" "${TE_anno_intact}" |
    bedtools getfasta -fi "$pangenome" -bed - > ${family}_LTR_selected_query.fa

    # Get the rest of the sequences of the annotation for the given family
    # important, very important, to remove the parent entries as they contain
    # structurtally intact LTRs
    grep -w "${family}" "${TE_anno}" | grep -v "Parent=" |
        cut -f1 -d ';' | awk '{print $1"\t"$4"\t"$5"\t"$9}' |
        bedtools getfasta -fi "$pangenome" -bed - -name |
        sed 's/::.*$//' >"${temp_fam_fasta}"

    # Align the LTR to the family items
    minimap2 ${family}_LTR_selected_query.fa "${temp_fam_fasta}" >"${temp_paf_file}"

    # Filter solo LTRs from the paf alignment file
    awk -v family=$family 'BEGIN{ OFS=FS="\t"} {
		if( $2 > 80 && $2 >= $7 * 0.8 && $2 <= $7 * 1.2 && $11 >= $7 * 0.8 && $11 <= $7 * 1.2  )
		print $1"\t"family"\tSolo_LTRs"}' "${temp_paf_file}" >"${out_name}_solo_candidates.tsv"
    # Calculate ratio per family:
    complete_counts=$(grep -w "${family}" "${TE_anno_intact}" | grep -v "Paret=" | wc -l)
    solo_counts=$(cat ${out_name}_solo_candidates.tsv | wc -l )
    total_count=$(echo "${solo_counts}/${complete_counts}")
    ratio=$(echo ${total_count} | bc -l )
    echo -e "${total_count}\t${ratio}\t${family}" |
    sed 's|/|\t|' | sed '1 i\Solo\tIntact\tRatio\tTEfam' > ${family}_solo_ratio.tsv

    # Cleanup
    rm "${temp_fam_fasta}" "${temp_paf_file}"
}

export -f retrieve_solo

# Generate a list with all the LTR families with more than 1 member
awk '{if($3 ~ /LTR/) print $9}' ${TE_anno} | grep -v "Parent" | cut -f2 -d ';' |
sed 's/Name=//;s/#.*$//' | sort | uniq -c   | awk '{if($1 > 1) print $2}' > LTR_family.list

# Filter out those that have at least a compelte match:

grep -f LTR_family.list ${TE_anno_intact} |
grep -v "Parent" | cut -f9 | cut -f2 -d ';'|
sed 's/Name=//;s/_INT//;s/_LTR//' |
sort | uniq > LTR_family.Wcompletes.list


# Run the function in parallel using $threads threads.
cat LTR_family.Wcompletes.list  | parallel -j $threads retrieve_solo {} "${TE_anno_intact}" "${TE_anno}" "${pangenome}" {}

# Remove empty  output files
find . -type f -name "*_LTR_selected_query.fa" -size 0 -delete
find . -type f -name "*_solo_candidates.tsv" -size 0 -delete

# Final file:
cat *_solo_candidates.tsv >  ALL_solo_LTRs.tsv
