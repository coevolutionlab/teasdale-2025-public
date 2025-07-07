#!/usr/bin/env bash

# This script runs EDTA in a combination of all 18 genomes in an attemp of proper TE name consistency among them.

conda activate TE_annotation/code/conda_env/EDTA_new

cd TE_annotation/output/EDTA/

EDTA="TE_annotation/code/EDTA/EDTA.pl"
genome="TE_annotation/output/EDTA/pangenome.fasta"
TAIR10_TE_lib="TE_annotation/input/TAIR10_TEs/TAIR10_mod_TElib_rDNA_centromeres_telomeres.fa"
cds="TE_annotation/input/Araport11_genes.201606.cds.fasta"


perl ${EDTA} --threads 25 --genome ${genome} --cds ${cds}  --sensitive 1  --anno 1 \
        --evaluate 1 --curatedlib ${TAIR10_TE_lib} |&  tee $(basename ${genome} .fasta)_EDTA_run.log

# Structurally intact LTR elements annotated by LTR_retriever had an ID duplication
# issue in the annotation, not a problem coordinate wise, but if parsing the
# 9th column can create some issues in downstream analyses, we fix it by running
# the custom script `fix_ID.py`

python3 /ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/fix_ID.py pangenome.fasta.mod.EDTA.TEanno.gff3
python3 /ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/fix_ID.py pangenome.fasta.mod.EDTA.intact.gff3

# Now we we backup the original annotations:
cp pangenome.fasta.mod.EDTA.TEanno.gff3 pangenome.fasta.mod.EDTA.TEanno_bckup.gff3
cp pangenome.fasta.mod.EDTA.intact.gff3 pangenome.fasta.mod.EDTA.intact_bckup.gff3
# And rename the fix version:
mv pangenome.fasta.mod.EDTA.TEanno_fix.gff3 pangenome.fasta.mod.EDTA.TEanno.gff3
mv pangenome.fasta.mod.EDTA.intact_fix.gff3 pangenome.fasta.mod.EDTA.intact.gff3

echo "DONE MAIN PIPELINE"
