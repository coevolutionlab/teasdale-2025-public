#!/bin/bash
source ~/.bashrc
conda activate ccsmeth
lima at6035_at6961/at6035_at6961.hifi_withKinetics.bam Sequel_16_Barcodes_v3.fasta at6035_at6961.hifi_withKinetics.demux.bam --hifi-preset SYMMETRIC --split-bam --split-named --split-subdirs

#rename 's/at9336_at9762.hifi_withKinetics.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA/at9336.hifi_withKinetics/' *
#rename 's/at9336_at9762.hifi_withKinetics.demux.bc1008_BAK8A_OA--bc1008_BAK8A_OA/at9762.hifi_withKinetics/' * 
