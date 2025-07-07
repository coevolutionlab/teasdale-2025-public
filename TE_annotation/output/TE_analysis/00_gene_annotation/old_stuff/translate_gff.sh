#!/bin/bash

# Default values
input_gff=""
genome_fasta="genome.fasta"

# Function to display usage information
usage() {
  echo "Usage: $0 -g <genome.fasta> -f <input.gff>"
  exit 1
}

# Parse command-line options
while getopts "g:f:" opt; do
  case $opt in
    g)
      genome_fasta="$OPTARG"
      ;;
    f)
      input_gff="$OPTARG"
      ;;
    \?)
      usage
      ;;
  esac
done

# Check if the input GFF file is provided
if [ -z "$input_gff" ]; then
  echo "Error: Please provide an input GFF file."
  usage
fi


# Check if the required tools are installed
if ! command -v gffread &> /dev/null; then
  echo "Error: Please make sure 'gffread' is installed."
  exit 1
fi

# Extract the base name of the input GFF file without any extension
output_base=$(basename -- "$input_gff")
output_base="${output_base%.*}"

# Generate the output file name
output_file="${output_base}.proteome.fa"

# Use gffread to extract and translate the CDS information from the GFF file
gffread -y "$output_file" -g "$genome_fasta" "$input_gff"



