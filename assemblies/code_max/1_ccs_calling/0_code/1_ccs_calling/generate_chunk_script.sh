#!/bin/bash

while getopts "n:s:p:q:o:t:h" opt; do
 case $opt in
	n)
	  NUMBER=$OPTARG >&2
	  ;;
	s)
	  SAMPLE=$OPTARG >&2
	  ;;
	p)
	  FPATH=$OPTARG >&2
	  ;;
	q)
	  QUALITY=$OPTARG >&2
	  ;;
	o)
	  OUTPATH=$OPTARG >&2
	  ;;
	t)
	  THREADS=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-n: number of chunks"
	  echo "-s: accession number (atXXXX)"
	  echo "-p: path to subreads.bam"
	  echo "-q: quality in percent (0.99=q20; 0.99=q30)"
	  echo "-o: path to write outfile.bam"
	  echo "-t: number of threads to use on cluster"
	exit 1
 esac
done

if [ "$QUALITY" == "99" ]
then
  qval=20
  qper=0.99
elif [ "$QUALITY" == "99.9" ]
then
  qval=30
  qper=0.999
else
  echo "wrong Q value input; please choose 99 (for q20) or 99.9 (for q30)"
fi



END=$NUMBER

for i in $(seq 1 $END) ; do
	echo source activate ccs >> $SAMPLE.Q$qval.chunk$i.sh
	echo ccs $FPATH $SAMPLE.CCS.Q$qval.$i.bam --chunk $i/$NUMBER -j $THREADS --min-rq $qper >> $SAMPLE.Q$qval.chunk$i.sh
	echo source deactivate ccs >> $SAMPLE.Q$qval.chunk$i.sh
done


