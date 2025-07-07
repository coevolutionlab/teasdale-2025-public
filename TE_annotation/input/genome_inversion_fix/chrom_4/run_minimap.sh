#!/bin/bash

# Extract chrom 4 both assemblies
seqkit grep -nrp "_chr4" at9879.fa  > at9879_chr4.fa
seqkit grep -nrp "Chr4"  IP-Per-0.Chr_scaffolds.fa > IP-Per-0.Chr_4.fa

# Run minimap2
minimap2  IP-Per-0.Chr_4.fa  at9879_chr4.fa > chrom4_al.paf
