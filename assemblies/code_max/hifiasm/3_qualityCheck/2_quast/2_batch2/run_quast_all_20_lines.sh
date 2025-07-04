#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta --fragmented --large \
-l at8285,at9104,at9336,at9503,at9578 \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at8285.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9104.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9336.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9503.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9578.p_ctg.noContamination.hifiasm.fasta 
