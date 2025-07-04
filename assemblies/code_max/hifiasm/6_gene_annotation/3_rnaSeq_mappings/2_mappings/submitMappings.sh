#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

for i in $(ls at*StarMappingScript.sh); do
	$QSUB 32 5 bash $i &
done
