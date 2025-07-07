#!/usr/bin/env bash
cd TE_annotation/input/TAIR10_TEs/
## Dowload  the curated version of the TAIR10 Transposable elements from the TAIR10 website.
#wget https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_transposable_elements/TAIR10_TE.fas
## Then, modify the headers to make them compatible with EDTA style:
#############
#>Hip5_12#DNA/Helitron
#>Hip6_5#DNA/Helitron
#>Hip7_1#DNA/Helitron
#>ZM00001_consensus#DNA/hAT
#>ZM00002_consensus#DNA/hAT
###########

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'  < TAIR10_TE.fas | sed '1d' > TAIR10_mod_TE.fa

cat TAIR10_mod_TE.fa |
paste - - |
cut -f1,5,6,7 -d '|' |
sed 's/|/_/;s/|/#/;s/|.*bp//' |
awk '{print $1"\n"$2}' > temp_TE

mv temp_TE TAIR10_mod_TE.fa

sed -i 's/RC_Helitron/DNA_Helitron/' TAIR10_mod_TE.fa
sed -i 's/En-Spm/EnSpm/'  TAIR10_mod_TE.fa

## Add centromeres, telomeres and rDNA clusters:

cat TE_annotation/input/otherRepeats/rDNA_centromeres6_telomeres.fa |
sed 's/CEN/CEN\/CEN/;s/S_rRNA/S\/rDNA/;s/telomere$/telomere\/telomere/'  | cat - TAIR10_mod_TE.fa > TAIR10_mod_TElib_rDNA_centromeres_telomeres.fa

# Use this library to run EDTA in the pangenome. 
