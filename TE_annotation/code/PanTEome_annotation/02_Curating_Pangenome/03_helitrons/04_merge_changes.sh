#!/usr/bin/env bash

# This script evaluates if there is a meaningful intersection between EAhelitron
# and Helitrons present in EDTA output.

cd TE_annotation/output/03_Curating_Helitrons/03_EAHelitron/

# FILES
pangenome_fasta="TE_annotation/output/DTA/pangenome.fasta"
pangenome_fai="TE_annotation/output/EDTA/pangenome.fasta.fai"
pangenome_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_02_TEannofull_intact_domain_info.gff3"
pangenome_intacts_GFF="TE_annotation/output/EDTA_curation/03_denovo_Helitrons/helitron_02_TEannointacts_intact_domain_info.gff3"

# Interect with the  ongoing annotation and add information to the annotation file:
bedtools sort -faidx  ${pangenome_fai}  -i 03_EAHelitron/FULL_LENGTH_HELITRONS.bed  |
bedtools intersect  -c -f 0.8  -a ${pangenome_GFF}  -b -  |
awk 'BEGIN{FS=OFS="\t"} {if($10 > 0 && $9 ~/Helitron/ ) print $1,$2,$3,$4,$5,$6,$7,$8,$9";EAhelitronOverlap=YES" ;
else print $1,$2,$3,$4,$5,$6,$7,$8,$9";EAhelitronOverlap=No"}'  > helitron_03_TEannofull_intact_domain_info_EAov.gff3

# Interect with the  ongoing annotation and add information to the annotation file:
bedtools sort -faidx  ${pangenome_fai}  -i 03_EAHelitron/FULL_LENGTH_HELITRONS.bed  |
bedtools intersect  -c -f 0.8  -a ${pangenome_intacts_GFF}  -b -  |
awk 'BEGIN{FS=OFS="\t"} {if($10 > 0 && $9 ~/Helitron/ ) print $1,$2,$3,$4,$5,$6,$7,$8,$9";EAhelitronOverlap=YES" ;
else print $1,$2,$3,$4,$5,$6,$7,$8,$9";EAhelitronOverlap=No"}' > helitron_03_TEannointacts_intact_domain_info_EAov.gff3


# Uncover unique EA Helitrons and format GFF:
bedtools intersect -v -a 03_EAHelitron/FULL_LENGTH_HELITRONS.bed  -b $pangenome_GFF  |
awk 'BEGIN{FS=OFS="\t"}
    { if($9 ~ /tra/)
        print $1,"EAHelitron\tRC/Helitron",$2,$3,".","-",".","ID="$4";Name=TE_EAhelitron;Classification=RC/Helitron;Sequence_ontology=SO:0000544;Identity=NA;Info=EAhelitron_lowconf_helitron" ;
      else print $1,"EAHelitron\tRC/Helitron",$2,$3,".","+",".","ID="$4";Name=TE_EAhelitron;Classification=RC/Helitron;Sequence_ontology=SO:0000544;Identity=NA;Info=EAhelitron_lowconf_helitron"
    }' > unique_helitrons_EAhelitron.gff3





# Concat and sort both GFF files:
cat helitron_03_TEannofull_intact_domain_info_EAov.gff3 unique_helitrons_EAhelitron.gff3  |
bedtools  sort -i - -faidx  ${pangenome_fai}  > helitron_03_TEannointacts_intact_domain_info_EAov_EAlowc.gff3
# Remove old file to avoid confusion:
rm helitron_03_TEannofull_intact_domain_info_EAov.gff3

echo "DONE!"
