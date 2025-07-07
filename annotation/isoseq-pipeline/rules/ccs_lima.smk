rule ccs:
    """
    Create HiFi reads from SequelII IsoSeq subreads
    """
    input:
        "../input/subreads/{pool}.subreads.bam"
    output:
        "output/ccs/{pool}/{pool}.hifi.bam"
    log:
        "log/ccs/{pool}/{pool}.ccs.log"
    params:
        outdir="output/ccs/{pool}",
        prefix="output/ccs/{pool}/{pool}"
    threads: 64
    shell:
        "mkdir -p {params.outdir} && ccs --report-file {params.prefix}.report.txt --metrics-json {params.prefix}.metrics.json.gz --hifi-summary-json {params.prefix}.hifi-summary.json --num-threads {threads} --log-level INFO --log-file {log} {input} {output}"

# lima

rule lima:
    """
    Demultiplex the pools and remove primers + barcodes (TO DO: do the barcodes present also contain primers? --> Barcodes + universal primers from the downloaded isoseq file)
    """
    input:
        hifi="output/ccs/{pool}/{pool}.hifi.bam",
        biosamples="../input/meta/biosamp_{pool}.csv",
        barcodes="../input/meta/pb16_barcodes_uniprimers.fasta"
    output: 
        directory("output/lima/{pool}")
    log:
        "log/lima/{pool}.lima.log"
    params:
        pattern="output/lima/{pool}/{pool}.demux.hifi.bam"
    threads: 64
    shell:
        "mkdir -p {output} && lima --isoseq --peek-guess --min-length 100 --num-threads {threads} --log-level INFO --log-file {log} --store-unbarcoded --split-bam-named --biosample-csv {input.biosamples} {input.hifi} {input.barcodes} {params.pattern}"
