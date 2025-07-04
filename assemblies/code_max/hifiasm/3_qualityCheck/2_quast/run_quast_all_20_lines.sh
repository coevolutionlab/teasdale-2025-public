#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects7/diffLines_20/data/1_genomes/4_quality_check/TAIR10.fasta --fragmented --large \
-l at6137,at6923,at6929,at7143,at8285,at9104,at9336,at9503,at9578,at9744,at9762,at9806,at9830,at9847,at9852,at9879,at9883,at9900 \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6137.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6923.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at6929.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at7143.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at8285.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9104.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9336.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9503.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9578.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9744.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9762.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9806.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9830.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9847.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9852.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9879.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9883.p_ctg.noContamination.hifiasm.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/3_qualityCheck/4_blobTools/5_removeContamination/at9900.p_ctg.noContamination.hifiasm.fasta 
