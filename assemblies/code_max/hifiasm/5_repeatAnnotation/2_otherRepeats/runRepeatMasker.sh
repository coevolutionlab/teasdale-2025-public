#!/bin/bash

source activate /ebio/abt6_projects9/abt6_software/conda/repeat_tools/dfam-tetools_latest

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_repeatMaskerOut
	cd $NAME\_repeatMaskerOut
	nice RepeatMasker -pa 50 -nolow -gff -lib ../rDNA_centromeres6_telomeres.fa ../$i
	cd ../
done
