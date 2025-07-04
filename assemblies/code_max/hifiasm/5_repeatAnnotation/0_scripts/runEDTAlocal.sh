#!/bin/bash

source activate edta_new

QSUB="/ebio/abt6//mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
EDTA="/ebio/abt6/mcollenberg/miniconda3/envs/edta_new/bin/EDTA.pl"

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	nice $EDTA --threads 25 \
	--genome $i \
	--sensitive 1 \
	--anno 1 \
	--cds /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/Araport11/release-201606/Araport11_genes.201606.cds.fasta &
done
