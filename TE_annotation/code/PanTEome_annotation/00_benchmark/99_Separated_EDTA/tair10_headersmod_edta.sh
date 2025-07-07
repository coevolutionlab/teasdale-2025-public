#Dowload  the curated version of the TAIR10 Transposable elements from the TAIR10 website.

#https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_transposable_elements/TAIR10_TE.fas

#Then modify the headers to make them compatible with EDTA style:

#############
#>Hip5_12#DNA/Helitron
#>Hip6_5#DNA/Helitron
#>Hip7_1#DNA/Helitron
#>ZM00001_consensus#DNA/hAT
#>ZM00002_consensus#DNA/hAT
###########

cd /ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/TElib/TElib/TAIR10_TEs/TAIR10lib_EDTA/

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'  < TAIR10_TE.fas | sed '1d' > TAIR10_mod_TE.fa

cat TAIR10_mod_TE.fa |
paste - - |
cut -f1,5,6,7 -d '|' |
sed 's/|/_/;s/|/#/;s/|.*bp//' |
awk '{print $1"\n"$2}' > temp_TE

mv temp_TE TAIR10_mod_TE.fa

sed -i 's/RC_Helitron/DNA_Helitron/' TAIR10_mod_TE.fa
sed -i 's/En-Spm/EnSpm/'  TAIR10_mod_TE.fa
