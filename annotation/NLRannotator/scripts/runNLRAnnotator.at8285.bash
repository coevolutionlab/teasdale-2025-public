#!/bin/bash
accession=at8285
nice java -jar \
    NLR-Annotator-v2.1b.jar -i ../../assembly-and-annotation/output/01_assembly/03_inversion_fixed/${accession}.fasta \
    -x src/mot.txt -y src/store.txt \
    -t 32 -o ../output/${accession}_nlr_annotator.txt \
    -b ../output/${accession}_nlr_annotator.bed \
    -g ../output/${accession}_nlr_annotator.gff3
