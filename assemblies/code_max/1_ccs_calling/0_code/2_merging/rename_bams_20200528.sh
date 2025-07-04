#!/bin/bash

while getopts "q:h" opt; do
 case $opt in
	q)
	  QVAL=$OPTARG >&2
	  ;;
	h)
	  echo "Help"
	  echo "-q: qvalue to change file to"
	exit 1
 esac
done


for i in $(ls at*.CCS.Q20.*.bam); do
	ACC=$(echo $i | awk -F'.' '{print $1}')
	NO=$(echo $i | awk -F'.' '{print $4}')
	mv $i $ACC.CCS.$QVAL.$NO.bam
done

for i in $(ls at*.CCS.Q20.*.bam.pbi); do
	ACC=$(echo $i | awk -F'.' '{print $1}')
	NO=$(echo $i | awk -F'.' '{print $4}')
	mv $i $ACC.CCS.$QVAL.$NO.bam.pbi
done
