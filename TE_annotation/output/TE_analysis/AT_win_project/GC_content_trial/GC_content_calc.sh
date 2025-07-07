#!/usr/bin/env bash

# This script calculates GC content

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }

[ $# -eq 0 ] && usage

while getopts ":h:g:w:s:o" arg; do
  case $arg in
    g) # path to genome in fasta format
      genome=${OPTARG}
      ;;
    w) # Window size (in integers) to calculate GC content
      window_size=${OPTARG}
      ;;
    s) # Step of the sliding window.
      step_size=${OPTARG}
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done

# VARS
full_genome_path=$(realpath "$genome")
genome_name=$(basename -- "$genome")
genome_name="${genome_name%.*}"

# Check whether FAI file is present otherwise create it
if [ ! -f "${full_genome_path}.fai" ]; then
    echo "${genome}.fai not found. Creating one with samtools faidx..."
    samtools faidx "$full_genome_path"
    echo "Done!"
fi

# Get the GC per step_size windows
bedtools makewindows -g "${full_genome_path}.fai" -w "$window_size" -s "$step_size" |
bedtools nuc -fi "$full_genome_path" -bed - > ${genome_name}_${window_size}_win_S${step_size}_nuc.bed



# Intersect away the repeat annotation files (CHANGE THIS)

panTErDNA="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/01_build_summary/pangenome_rDNA_annotation.gff3"
panSat="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/01_build_summary/pangenome_sat_repeats_TRF_TRASH.gff3"
panTEanno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/01_build_summary/pangenome_TEannotation.gff3"

# Retrieve the header (will be lose in the intersect step)
header=$(head -n 1 ${genome_name}_${window_size}_win_S${step_size}_nuc.bed)

# Remove the windowsthat overlapevenfor 1bp with our GC win file. 

bedtools intersect -v -a ${genome_name}_${window_size}_win_S${step_size}_nuc.bed -b ${panTEanno} ${panSat} ${panTErDNA} > ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.bed 
# Add the header
sed -i "1 i ${header}" ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.bed 

#calculate average and variance of the GC content with awk

tail -n +2 ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.bed  | 
awk '{
  sum += $5
  sumsq += ($5 * $5)
  count++
}
END {
  average = sum / count
  variance = (sumsq / count) - (average * average)
  stddev = sqrt(variance)
  print "Average:\t", average
  print "Variance:\t", variance
  print "Standard Deviation:\t", stddev
}' > ${genome_name}_${window_size}_win_S${step_size}.clean.stats.tsv


cat ${genome_name}_${window_size}_win_S${step_size}.clean.stats.tsv

# Read out the 3 lines as varialbes to apply trhe filter:
avg=$(cat ${genome_name}_${window_size}_win_S${step_size}.clean.stats.tsv | grep "Average" | cut -f2)
var=$(cat ${genome_name}_${window_size}_win_S${step_size}.clean.stats.tsv | grep "Variance" | cut -f2)
stdev=$(cat ${genome_name}_${window_size}_win_S${step_size}.clean.stats.tsv | grep "Standard Deviation" | cut -f2)


# Treshold
low_tresh=$(echo "  $avg - (2 *  $stdev )" | bc)

# Apply teshold
awk -v low_tresh=$low_tresh '{if($5 < low_tresh) print $0}' ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.bed  |
sed "1 i ${header}" >  ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.filtered.bed

bedtools merge -i ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.filtered.bed -c 5 -o mean  |
awk '{print $0"\t"$3-$2}' | sed '1 i\#Chrom\tStart\tEnd\tGC_per\tSize_win' >  ${genome_name}_${window_size}_win_S${step_size}_nuc.clean.filtered.merged.bed
