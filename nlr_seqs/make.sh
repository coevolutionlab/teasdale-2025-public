<../annotation/final/nlr_table.csv \
    csvtk filter2 -f '${Curated_type}=="nlr"' |
    csvtk cut -f ID |
    tail -n +2 > nlr_genes.txt

zcat ../annotation/final/all_accesssions.hodgepodgemerged.sort.gff3.gz |
    grep -f nlr_genes.txt \
    >nlr_annotation.gff3

wc -l nlr_annotation.gff3

gffread \
    -y all_nlrs_cds.fa \
    -w all_nlrs_mrna.fa -S  \
    -g ../assemblies/output/all_accessions.fasta \
    nlr_annotation.gff3

bgzip -@12 -l 9 all_nlrs_cds.fa 
samtools faidx  all_nlrs_cds.fa.gz
bgzip -@12 -l 9 all_nlrs_mrna.fa 
samtools faidx  all_nlrs_mrna.fa.gz
