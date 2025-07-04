#!/bin/bash

while getopts "d:s:h" opt; do
 case $opt in
	d)
	  DIRECTORY=$OPTARG >&2
	  ;;
	s)
	  SAMPLE=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-d: directory where chunkXY.bam is stored"
	  echo "-s: sample name (atXXXX)"
	exit 1
 esac
done

for i in $SAMPLE.CCS.*.bam; do
	echo $PWD/$i >> $SAMPLE.2merge.fofn
done

