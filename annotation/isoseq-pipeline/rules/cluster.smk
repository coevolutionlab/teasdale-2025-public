rule cluster:
    """
    turn off!
    """
    input:
        "output/concat_samples/{sample}.ncfl.bam"
    output:
        "output/cluster/{sample}.transcripts.bam"
    log:
        "log/cluster/{sample}.cluster.log"
    threads: 12
    shell:
        "mkdir -p output/cluster && isoseq3 cluster -j {threads} --singletons --log-level INFO --log-file {log} {input} {output}"
