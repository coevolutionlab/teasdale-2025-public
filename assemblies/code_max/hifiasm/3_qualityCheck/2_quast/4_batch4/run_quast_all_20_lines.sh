#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta --fragmented --large \
-l at9852,at9879,at9883,at9900 \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9852.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9879.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9883.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9900.p_ctg.noContamination.hifiasm.fasta
