# ---
# jupyter:
#   jupytext:
#     formats: ipynb,sh:light
#     text_representation:
#       extension: .sh
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.0
#   kernelspec:
#     display_name: Bash
#     language: bash
#     name: bash
# ---

# # Step 5. Make alt contigs (specifically test set of contigs for short read genotyping)

conda activate dl20-orthologs
git annex get output/02_annotation/01_original-annotation-merged/at6137*
git annex get output/01_assembly/02_masked/at6137.scaffolds.unmasked.fasta*

mkdir -p tmp/ortho/mkseqs/ tmp/ortho/seqs

agat_convert_sp_gff2bed.pl \
    --gff output/02_annotation/01_original-annotation-merged/at6137.augustus-v2.3.gff3 \
    --sub transcript \
    --out tmp/ortho/mkseqs/at6137.transcript.bed

awk '{printf("%s:%d-%d(%s)\t%s|%s\n", $1, $2, $3, $6, $1, $4);}' \
    < tmp/ortho/mkseqs/at6137.transcript.bed \
    > tmp/ortho/mkseqs/at6137.renamer.tsv

bedtools getfasta \
    -s -fullHeader \
    -bed tmp/ortho/mkseqs/at6137.transcript.bed \
    -fi output/01_assembly/02_masked/at6137.scaffolds.unmasked.fasta \
    -fo tmp/ortho/seqs/at6137.transcript.fasta

seqkit replace -p '^(.*)$' -r '{kv}  $1' \
    -k tmp/ortho/mkseqs/at6137.renamer.tsv \
    tmp/ortho/seqs/at6137.transcript.fasta \
    >tmp/ortho/seqs/at6137.trascript.rename.fasta


