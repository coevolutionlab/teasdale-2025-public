#!/bin/bash

while getopts "n:h" opt; do
 case $opt in
	n)
	  NAME=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-n: accession name"
	exit 1
 esac
done



for i in $(find . -name "*_q*" -maxdepth 1 | awk -F'/' '{print $2}'); do
	Q=$(echo $i | awk -F'_' '{print $2}')
	cd $i
	cp ccs_report.txt $NAME.$Q.ccs_report.txt
	cd ../
done
