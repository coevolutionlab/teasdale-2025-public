rule rename_rg:
    input:
        "output/refine/{pool}/{pool}.{sample}.ncfl.bam"
    output:
        "output/rename_rg/{pool}/{pool}.{sample}.ncfl.bam"
    log:
        "log/rename_rg/{pool}.{sample}.rename_rg.log"
    params:
        dir=directory("output/rename_rg/{pool}"),
        pattern="{pool}_{sample}"
    threads: 4
    shell:
        "mkdir -p {params.dir} && python3 scripts/rg.py -t {threads} -i {input} -o {output} -d {params.pattern} |& tee {log}"


from collections import defaultdict

rule concat_samples:
    input:
        lambda wc: expand("output/rename_rg/{pool}/{pool}.{sample}.ncfl.bam",
                    pool=config["sample2pools"][wc.sample],
                    sample=wc.sample)
    output:
        "output/concat_samples/{sample}.ncfl.bam"
    log:
        "log/concat_samples/{sample}.ncfl.log"
    shell:
        "mkdir -p output/concat_samples && samtools merge {output} {input} |& tee {log}"
