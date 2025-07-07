rm -rf www/
blsl genigvjs \
    --title 'DL20 Teasdale et al 2025 CHM Genome Browser' \
    --copy \
    --outdir www/ \
    --reference ../assemblies/output/all_accessions.fasta \
    ../annotation/final/all_accesssions.hodgepodgemerged.sort.gff3.gz \
    ../neighbourhoods/neighbourhoods.bed.gz 
