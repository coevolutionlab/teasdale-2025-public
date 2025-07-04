#!/bin/bash

MINIDOT="/ebio/abt6_projects9/abt6_software/bin/miniasm/minidot"

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_mappings
	$MINIDOT $NAME.p_ctg.chrMchrC.PAF > $NAME.p_ctg.chrMchrC.ps &
	cd ../
done

