#!/usr/bin/env bash

# This function calculates first intronic sequences wthin genes and adds them to the gff file:
# Needs bedops instaled 

# Input vars:
Gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest/ALL_accessions.representatives.gff3"
# Retrieve all genes:
awk '{if($3 == "gene") print $0}' ${Gene_anno} > only_genes.gff3
# Retrieve allexons:
awk '{if($3 == "exon") print $0}' $Gene_anno > only_exons.gff3
# Retrieve gene introns:
gff2bed < only_genes.gff3 > only_genes.bed
gff2bed < only_exons.gff3 > only_exons.bed
# Calculate introns
bedops --difference only_genes.bed only_exons.bed > only_introns.bed
# Assign these introns back to gene ids:
bedtools intersect -wo -a only_genes.gff3 -b only_introns.bed |
awk 'BEGIN{OFS="\t"} {sub(/;.*$/, "", $9); print $10,"DL20","intron",$11,$12,$6,$7,$8,$9}' > introns_identified.gff

# ID file:
mkdir -p tmp_folder
cut -f9 introns_identified.gff | uniq  > tmp_folder/ID_file_list.txt 
cd ./tmp_folder/
split -l 5000 ID_file_list.txt 
# Make the introns files:
counter=1
for ids in x*; do 
    # Create an output file for each input file
    output_file="introns_identified_${counter}.gff"
    # Perform operations on the current input file
    grep -wf "$ids" ../introns_identified.gff > "$output_file"
    # Increment the counter for the next iteration
    ((counter++))
    rm $ids
done
rm ID_file_list.txt
#########
# Funciton to add counts to introns:
process_intron_file() {
	input_file=$1
	output_file=$2

    declare -A counter_introns
    
    while IFS=$'\t' read -r -a line; do
        value="${line[8]}"
        
        if [[ -n "${value}" ]]; then
            count=$((++counter_introns["$value"]))
            formatted_count=$(printf "%02d" "$count")
            line[9]="${value}_intron${formatted_count}"
        fi
    
        echo -e "${line[@]}"
    done < ${input_file} > ${output_file}
    sed -i 's/ /\t/g' ${output_file}  
    unset counter_introns
}
export -f process_intron_file
# Run function in parallel:
find . -maxdepth 1 -type f -name "introns_identified_*gff" |
parallel -j 10 'output_file="introns_ID_counts_{#}.gff3"; process_intron_file {} $output_file'
#  merge output files 
cat introns_ID_counts_*gff3 > ../introns_ID_counts.gff3
cd ../
# cleanuyp stuff
rm -rf ./tmp_folder/
# Rearrange and create final intron class gff:
awk 'BEGIN{OFS="\t"}  
{gsub("ID=", "parent=", $9); 
print $1, $2, $3, $4, $5, $6, $7, $8, $10";"$9}' introns_ID_counts.gff3 > intron_final.gff3 
# cleanup
rm only_genes.gff3 only_exons.gff3 only_genes.bed only_exons.bed
rm only_introns.bed introns_identified.gff introns_ID_counts.gff3
######
cat $Gene_anno intron_final.gff3  | 
sort -k1,1V -k4,4n -k5,5n   > final.gff3
