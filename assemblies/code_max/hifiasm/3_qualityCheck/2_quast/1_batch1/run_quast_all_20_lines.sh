#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta --fragmented --large \
-l at6035,at6137,at6923,at6929,at7143 \
/ebio/abt6_projects7/diffLines_20/data/1_genomes/hifiasm/1_assembly/remaining2/at6035_hifiasmResults/at6035.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6137.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6923.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6929.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at7143.p_ctg.noContamination.hifiasm.fasta 
