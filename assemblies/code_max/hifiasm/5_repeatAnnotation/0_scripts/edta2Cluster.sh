#!/bin/bash

source activate edta_new

QSUB="/ebio/abt6//mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
EDTA="/ebio/abt6/mcollenberg/miniconda3/envs/edta_new/bin/EDTA.pl"
export PATH="/ebio/abt6/mcollenberg/miniconda3/envs/edta_new/bin:$PATH"

$EDTA --threads 30 \
--genome $XXXZZZ.scaffolds.fasta \
--sensitive 1 \
--anno 1 \
--cds /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/Araport11/release-201606/Araport11_genes.201606.cds.fasta 
