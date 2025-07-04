#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta --fragmented --large \
-l at9744,at9762,at9806,at9830,at9847 \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9744.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9762.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9806.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9830.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9847.p_ctg.noContamination.hifiasm.fasta 
