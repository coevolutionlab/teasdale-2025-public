#!/usr/bin/env bash

# This script remove the Unknown TE models from the TE library and the Unknown's
# from the GFF annotation.
mkdir -p TE_annotation/output/EDTA_curation/02_unknowns
cd TE_annotation/output/EDTA_curation/02_unknowns

# Current GFF file:
pangenome_GFF="TE_annotation/output/EDTA_curation/01_Tandem_repeats/pangenome.fasta.mod.EDTA.TEanno.sat.clean.gff3"
pangenome_TElib="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.fa"
pangenome_TElib_novel="TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.TElib.novelfa"

# Remove Unknowns from the annotation
awk 'BEGIN{OFS=FS="\t"}{if($9 !~ /Classification=Unknown/) print $0}' ${pangenome_GFF} > pangenome.fasta.mod.EDTA.TEanno.sat.clean.no_unknowns.gff3
# Remove Unknowns from the TE models
seqkit grep -nrvp "TE.*#Unknown" ${pangenome_TElib} > pangenome.fasta.mod.EDTA.TElib.fa
seqkit grep -nrvp "TE.*#Unknown" ${pangenome_TElib_novel} > pangenome.fasta.mod.EDTA.TElib.novel.fa
