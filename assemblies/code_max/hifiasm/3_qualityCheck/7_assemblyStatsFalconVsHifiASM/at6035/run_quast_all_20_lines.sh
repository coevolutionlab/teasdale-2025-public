#!/bin/bash

set -vx

nice python /ebio/abt6_projects9/abt6_software/bin/quast/quast.py -t 120 -o $PWD -r /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta --fragmented --large \
-l at6035 \
/ebio/abt6_projects7/diffLines_20/data/1_genomes/hifiasm/1_assembly/remaining2/at6035_hifiasmResults/at6035.hifiASM.p_ctg.fasta
