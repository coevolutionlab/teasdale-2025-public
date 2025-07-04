#!/bin/bash

source activate augustus3.3.3

for i in $(ls at*.softmasked.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	augustus --species=BUSCO_$NAME\_buscoResults --softmasking=1 --hintsfile=$NAME.liftoff.hints --extrinsicCfgFile=/tmp/global2/mcollenberg/data/diff_lines/hifiasm/6_gene_annotation/4_augustus/2_buscoLiftoff/newtest.cfg --gff3=on $i >> $NAME.softmasked.final.gff3 &
done


