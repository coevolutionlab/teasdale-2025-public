#!/bin/bash

export PATH=/ebio/abt6_projects9/abt6_software/bin/minimap2:$PATH
export PATH=/ebio/abt6_projects9/abt6_software/bin/miniasm:$PATH

while getopts "a:t:o:h" opt; do
 case $opt in
	a)
	  INFILE=$OPTARG >&2
	  ;;
	t)
	  THREADS=$OPTARG >&2
	  ;;
	o)
	  OUTNAME=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-a: infile (atXXXX_polished.fasta)"
	  echo "-t: number of threads"
	  echo "-o: outname"
	exit 1
 esac
done

#NAME=$(echo $INFILE | awk -F"_" '{print $1}')

minimap2 -x asm5 -t $THREADS /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/TAIR10/TAIR10_chr_all.renamed.fas $INFILE > $OUTNAME.PAF
minidot $OUTNAME.PAF > $OUTNAME.ps

