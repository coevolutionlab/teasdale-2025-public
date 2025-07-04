#!/bin/bash

set -vx

python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 200 -o $PWD -r /ebio/abt6_projects7/diffLines_20/data/1_genomes/4_quality_check/TAIR10.fasta --fragmented --large \
-l at8285.hifiasm,at8285_falcon,at9578.hifiasm,at9578_falcon,at9744_hifiasm,at9744_falcon,at9503_hifiasm,at9503_falcon,at9852_hifiasm,at9852_falcon \
at8285.hifiASM.p_ctg.fasta \
at8285_polished.fasta \
at9578.hifiASM.p_ctg.fasta \
at9578_polished.fasta \
at9744.hifiASM.p_ctg.fasta \
at9744_polished.fasta \
at9503.hifiASM.p_ctg.fasta \
at9503_polished.fasta \
at9852.hifiASM.p_ctg.fasta \
at9852_polished.fasta
