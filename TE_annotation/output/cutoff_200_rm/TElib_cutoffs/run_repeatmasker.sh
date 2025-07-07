#!/usr/bin/env bash

usage() { echo "
####
Running RepeatMasker without library is no good! Bad Bad.
The recommended format for IDs in a custom library is:
 >repeatname#class/subclass
 or simply
 >repeatname#class
####
USAGE:
" && grep " .)\ #" $0; exit 0; }

[ $# -eq 0 ] && usage

while getopts "g:h:l:c:t:" arg; do
  case $arg in
    g) # path to genome  in fasta format
      genome=${OPTARG}
      ;;
    l) # path to the TE library to mask with
      custom_lib=${OPTARG}
      ;;
    c) # cutoff threshold (in integers)
      cutoff=${OPTARG}
      ;;
    t) # threads (in integers)
      threads=${OPTARG}
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done

##### The recommended format for IDs in a custom library is:
# >repeatname#class/subclass
# or simply
# >repeatname#class


## log name
genome_name=$(basename "$genome")
genome_name="${genome_name%.*}"

##### Actual Comand
/ebio/abt6_projects9/abt6_software/bin/repeatmasker-4.0.5/RepeatMasker $genome \
-e  ncbi \
-s \
-a \
-inv \
-xsmall \
-div 40 \
-lib $custom_lib \
-no_is \
-nolow  \
-par $threads \
-cutoff $cutoff \
-dir ./ \
-norna \
-gff |& tee repeatmasker_${genome_name}.log
