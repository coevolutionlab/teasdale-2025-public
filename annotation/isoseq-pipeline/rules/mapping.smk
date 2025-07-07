rule bam2fastq:
    input:
        "output/concat_samples/{sample}.ncfl.bam"
    output:
        "output/concat_samples/{sample}.ncfl.fastq"
    log:
        "log/bam2fastq/{sample}.transcripts.bam2fastq.log"
    shell:
        "bedtools bamtofastq -i {input} -fq {output} |& tee {log}" #doubles reads
      #  "samtools bam2fq {input} > {output} |& tee {log}" #mappin with pbmm2 does not work and warnings in minimap2: ([M::worker_pipeline::211.727*9.74] mapped 248864 sequences [WARNING] wrong FASTA/FASTQ record. Continue anyway. CAUSED BY "|&": https://stackoverflow.com/questions/35917552/what-does-the-syntax-mean-in-shell-language)


rule rm_dups:
    input:
        "output/concat_samples/{sample}.ncfl.fastq"
    output:
        "output/concat_samples/{sample}.ncfl.no_dups.fastq"
    log:
        "log/rm_dup_fq/{sample}.ncfl.no_dups.log"
    params:
        stats="output/concat_samples/{sample}.ncfl.dups.stats"
    priority: 50
    threads: 4
    shell:
        "cat {input} | paste - - - - | sort -k1,1 -S 3G | tr '\t' '\n'  | seqkit rmdup -n -j {threads} -D {params.stats} -o {output} |& tee {log}"


# mapping

rule mapping_pbmm2:
    input:
        ref="input/refs/{sample}.scaffolds-v2.3.fasta",
        transcripts="output/concat_samples/{sample}.ncfl.no_dups.fastq"
    output:
        "output/mapping_pb/{sample}.mapped.bam"
    log:
        "log/mapping_pb/{sample}.mapping.log"
    threads: 10
    shell:
        "mkdir -p output/mapping_pb && pbmm2 align --preset ISOSEQ --sort --log-level INFO --log-file {log} {input.transcripts} {input.ref} {output}"

rule mapping_minimap:
    """
    Map the reads against the genome. Don't use pbmm2, as I don't know if -ax splice is enabled here, which is required for StringTiea, BUT use the equivalent parameters as ISOSEQ preset from pbmm2 (https://github.com/lh3/minimap2/issues/769).
    """
    input:
        ref="input/refs/{sample}.scaffolds-v2.3.fasta",
        transcripts="output/concat_samples/{sample}.ncfl.no_dups.fastq"
    output:
        "output/mapping_minimap/{sample}.mapped.bam"
    log:
        "log/mapping_minimap/{sample}.mapping.log"
    threads: 10
    shell:
        "mkdir -p output/mapping_minimap && minimap2 -t {threads} -ax splice:hq -MD -k 15 -w 5 -O 2,32 -E 1,0 -A 1 -B 2 -z 200,100 -r 200000 -g 2000 -C5 -G 200000 {input.ref} {input.transcripts} | samtools sort -l 9 -o {output} |& tee -a {log}"

rule minimap_index:
    input: 
        "output/mapping_minimap/{sample}.mapped.bam"
    output:
        "output/mapping_minimap/{sample}.mapped.bam.bai"
    log: 
        "log/mapping_minimap/{sample}.indexed.log"
    threads: 10
    shell:
        "samtools index -o {output} {input} |& tee {log}"

