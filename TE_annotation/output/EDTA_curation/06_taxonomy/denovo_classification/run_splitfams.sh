#!/usr/bin/env bash

input_dir="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/"
pangenome_TElib=${input_dir}"pangenome.TElib.novel.newTEfams.fa"

mkdir -p {Lines,LTR,TIR,Helitrons}

# Lines TE models
awk '/LINE/'  TE_family_list.txt TE_family_list.txt  > Lines/TE_family_Lines.tsv
seqkit grep -w 0 -nrf Lines/TE_family_Lines.tsv  $pangenome_TElib > Lines/pangenome_TElib_Lines.fa
# TIR TE models
awk '/DNA|MITE/ && !/Helitron/' TE_family_list.txt  > TIR/TE_family_TIR.tsv
seqkit grep -w 0 -nrf TIR/TE_family_TIR.tsv $pangenome_TElib > TIR/TE_family_classification_TIR.fa
# LTR TE models
awk '/LTR/'  TE_family_list.txt  > LTR/TE_family_LTR.tsv
seqkit grep -w 0 -nrf LTR/TE_family_LTR.tsv $pangenome_TElib > LTR/TE_family_classification_LTR.fa
# Helitron TE models
awk '/Helitron/'  TE_family_list.txt  > Helitrons/TE_family_Helitron.tsv
seqkit grep -w 0 -nrf Helitrons/TE_family_Helitron.tsv $pangenome_TElib > Helitrons/TE_family_classification_Helitron.fa
