#!/bin/bash

set -vx

python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects7/diffLines_20/data/1_genomes/4_quality_check/TAIR10.fasta --fragmented --large \
-l at8285,at9503,at9578,at9744,at9852,at6929,at7143,at9104,at9336,at9762,at9806,at9830,at9847,at9879,at9883,at6137,at6923,at9900 \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at8285/at8285.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9503/at9503.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9578/at9578.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9744/at9744.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9852/at9852.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at6929_hifiasmResults/at6929.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at7143_hifiasmResults/at7143.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9104_hifiasmResults/at9104.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9336_hifiasmResults/at9336.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9762_hifiasmResults/at9762.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9806_hifiasmResults/at9806.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9830_hifiasmResults/at9830.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9847_hifiasmResults/at9847.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9879_hifiasmResults/at9879.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9883_hifiasmResults/at9883.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at6137_hifiasmResults/at6137.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at6923_hifiasmResults/at6923.hifiASM.p_ctg.fasta \
/tmp/global2/mcollenberg/data/diff_lines/hifiasm/1_assembly/at9900_hifiasmResults/at9900.hifiASM.p_ctg.fasta
