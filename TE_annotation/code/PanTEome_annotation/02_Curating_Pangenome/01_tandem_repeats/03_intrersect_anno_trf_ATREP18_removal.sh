#!/usr/bin/env bash

# This script intersects TRASH output with TE annotations to remove TEs that fall within tandem repeat regions.
# We use a 80% treshold of overlap of the TE within the Cluster.

cd  TE_annotation/output/EDTA_curation/01_Tandem_repeats/

#FILES:
trf_gff="TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRF/pangenome.fasta.2.7.7.80.10.1000.2000.gff"
trash_gff="TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRASH/all.repeats.from.pangenome.fasta.gff"
pangenome_anno="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TEanno.gff3"
pangenome_intact="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.intact.gff3"
# TRASH  does a pooor job at the telomeres but a great job at the centromeres.
# TRF does a good job overall, but it lacks sensibility in the centromeres.

# Remove all TRF hits explained by TRASH
bedtools subtract -A -a ${trf_gff} -b ${trash_gff} > subs_temp.gff

# Merge them with TRASH original output
cat ${trash_gff} |
cat - subs_temp.gff |
sort -k1,1V -k4,4n -k5,5n > combined_temp.gff

# Create a header for this new file
header=$(printf "##gff-version 3.2.1\n##date $(date +'%Y-%m-%d %H:%M:%S')\n##source TRF and TRASH satellite annotation \n")
printf "%s\n" "$header" > temp_header
cat temp_header combined_temp.gff  > pangenome_sat_repeats_TRF_TRASH.gff3

# cleanup
rm subs_temp.gff
rm temp_header
rm combined_temp.gff

# MAIN: Clean the TE annotation of  satellite repeats.

bedtools intersect -v -F 0.2 -a ${pangenome_anno} -b pangenome_sat_repeats_TRF_TRASH.gff3 > pangenome.fasta.mod.EDTA.TEanno.sat.clean.gff3


# No need to perform this step to the intact file, as we have high confidence on those.

# Side note, ATREP18.

# I manually looked at instances of ATREP18 and they are just mainly SATELLITE DNA. Also some reports: doi: 10.1093/nar/gkx524
# already talk about ATREP18 beng composed by telomeric repeats.
# Therefore I will remove from any ATREP18 instance from the annotation.
grep -v "ATREP18" pangenome.fasta.mod.EDTA.TEanno.sat.clean.gff3 > tmp
mv tmp pangenome.fasta.mod.EDTA.TEanno.sat.clean.gff3
