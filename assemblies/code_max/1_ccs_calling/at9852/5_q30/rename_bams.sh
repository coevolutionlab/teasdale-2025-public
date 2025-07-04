#!/bin/bash

for i in $(ls at*.CCS.Q20.*.bam); do
	ACC=$(echo $i | awk -F'.' '{print $1}')
	NO=$(echo $i | awk -F'.' '{print $4}')
	mv $i $ACC.CCS.Q30.$NO.bam
done

for i in $(ls at*.CCS.Q20.*.bam.pbi); do
	ACC=$(echo $i | awk -F'.' '{print $1}')
	NO=$(echo $i | awk -F'.' '{print $4}')
	mv $i $ACC.CCS.Q30.$NO.bam.pbi
done
