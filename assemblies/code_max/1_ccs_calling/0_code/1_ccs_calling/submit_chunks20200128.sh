#!/bin/bash

while getopts "q:t:m:h" opt; do
 case $opt in
	q)
	  QSUB=$OPTARG >&2
	  ;;
	t)
	  THREADS=$OPTARG >&2
	  ;;
	m)
	  MEMORY=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-q: path to qsub script"
	  echo "-t: number of threads"
	  echo "-m: memory (GB)"
	exit 1
 esac
done

for i in *.sh; do
	$QSUB $THREADS $MEMORY bash $i
done
