#!/bin/bash


STAR --readFilesIn /tmp/global2/mcollenberg/data/diff_lines/rnaseqMappings/1_readFiles/HybridNecrosis_TxC_R1.fastq /tmp/global2/mcollenberg/data/diff_lines/rnaseqMappings/1_readFiles/HybridNecrosis_TxC_R2.fastq \
--runThreadN 32 \
--alignIntronMax 6000 \
--alignMatesGapMax 6000 \
--genomeDir /tmp/global2/mcollenberg/data/diff_lines/hifiasm/6_gene_annotation/3_rnaSeq_mappings/1_starIndices/at9883_starIndex \
--outFilterIntronMotifs RemoveNoncanonical \
--outFilterMismatchNmax 10 \
--outFilterMultimapNmax 1 \
--outReadsUnmapped None \
--outSAMattributes NH HI AS nM NM MD jM jI XS \
--outSAMtype BAM SortedByCoordinate \
--runMode alignReads \
--twopassMode Basic \
--limitBAMsortRAM 6478551302 \
--outFileNamePrefix hybridNecrosis_at9883
