rule refine:
    """
    Remove polyAtails and filter for concatamers (primers required again) (TO DO: do the barcodes present also contain primers?, Read about average PolyA tail length in Ara?, Does G in PolyA disturb analysis, make benchmarking on read retainment)
    """
    input:
        reads="output/lima/{pool}/{pool}.demux.hifi.{sample}.bam",
        primers="input/meta/pb16_barcodes_uniprimers.fasta"
    output:
        "output/refine/{pool}/{pool}.{sample}.ncfl.bam"
    log:
        "log/refine/{pool}.{sample}.refine.log"
    params:
        dir=directory("output/refine/{pool}")
    threads: 4
    shell:
        "mkdir -p {params.dir} && isoseq3 refine -j {threads} --require-polya --log-level INFO --log-file {log} {input.reads} {input.primers} {output}"
