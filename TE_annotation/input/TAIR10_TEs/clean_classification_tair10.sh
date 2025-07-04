#!/usr/bin/env bash

# Create a file with a consistet superfamily nomenclature for the TAIR10 TE families.


cut -f5,6 TAIR10_Transposable_Elements.txt | head -n1 >   header.tmp
cut -f5,6 TAIR10_Transposable_Elements.txt | tail -n +2 | sort | uniq > all_sorted.tmp

# Split  by column

cat all_sorted.tmp | cut -f 1 > families.tmp
cat all_sorted.tmp | cut -f 2 > superfamilies.tmp

# Do the changes to the superfamily column
sed -i 's/LINE?/LINE/;
s/LINE\/L1/LINE/;
s/LINE\/unknown/LINE/;
s/RathE[1,2,3]_cons/SINE/;
s/DNA\/helitron/RC\/Helitron/;
s/LTR_retrotransposon/\tLTR_unknown/;
s/Gypsy_LTR_retrotransposon\t/LTR_Ty3\t/;
s/L1_LINE_retrotransposon/LINE/;
s/DTA/HAT/;
s/DTC/CACTA/;
s/DTH/Harbinger/;
s/DTM/Mutator/;
s/DTT/Mariner/;
s/EnSpm/CACTA/;
s/En-Spm/CACTA/;
s/MuDR/Mutator/;
s/Pogo/Mariner/;
s/Tc1/Mariner/;
s/Copia/Ty1/;
s/Gypsy/Ty3/;
s/TIR\/CACTA_CACTA/DNA\/CACTA/;
s/DNA\/Helitron/RC\/Helitron/
' superfamilies.tmp

# Merge

paste families.tmp superfamilies.tmp  |
cat header.tmp - >  TAIR10_Transposable_Elements_classification.tsv
# Fix SADHU family
sed -i 's/SADHU\tUnassigned/SADHU\tSINE/' TAIR10_Transposable_Elements_classification.tsv

# Cleanup

rm header.tmp
rm all_sorted.tmp
rm families.tmp
rm superfamilies.tmp
