#!/usr/bin/env bash

# This script retrieves the genome coordinates and ORF aminoacid sequences of a given intergenic interval from the file:
"Number_orfs_per_intergenic_interval_window.tsv"
# Needs the following files in the same  directory 

usage() { echo "$0 usage:
This script retrieves the genome coordinates and ORF aminoacid sequences of a given intergenic interval from the file: Number_orfs_per_intergenic_interval_window.tsv'
Needs the following files in the same  directory as the script:
 ORFS_Intergenic_Region.orfs
 Intergenic_intervals_named.bed
Flags:
" && grep " .)\ #" $0; exit 0; }

[ $# -eq 0 ] && usage

while getopts ":g:n:t:h" arg; do
  case $arg in
    g) # path to genome in fasta format
      genome=${OPTARG}
      ;;
    n) # String containing the name of the interval. Ex: intergenic_interval_1480364_2
      Name=${OPTARG}
      ;;
    t) # Step of the sliding window.
      threads=${OPTARG}
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done


# Retrieve genomic coordiates
grep -w "$Name" Intergenic_intervals_named.bed |
sed '1 i\Accession_chrom\tStart\tEnd\tIntergenic_interval_name'
grep -w "$Name" Intergenic_intervals_named.bed > Filtered_${Name}_genomic_coordinates.bed

# Retrieve the fasta seq

bedtools getfasta -fi $genome -bed Filtered_${Name}_genomic_coordinates.bed > Filtered_${Name}_genomic_coordinates.fa

# Retrieve orfs
echo "Retrieving selected orfs from ${Name} using ${threads}."
echo "This takes a while...."

seqkit grep -j $threads -nrp "${Name}_.*" ./ORFS_Intergenic_Region.orfs  > Filtered_${Name}_ORFs.orfs
