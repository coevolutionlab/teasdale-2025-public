#!/bin/bash
set -xe

for orthogroup in $(cat tmp/just_manually_annotated_final_actual/nlr_containing_orthogroups.txt)
do 
mafft --auto tmp/just_manually_annotated_final_actual/just_nlr_containing_orthogroups/${orthogroup}.fa > tmp/just_manually_annotated_final_actual/just_nlr_containing_orthogroups/${orthogroup}_mafft.fa
done