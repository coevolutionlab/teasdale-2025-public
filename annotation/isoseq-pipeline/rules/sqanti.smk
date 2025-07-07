### SET PYTHONPATH!
#export PYTHONPATH=$PYTHONPATH:/ebio/abt6/lvaness/software/cDNA_Cupcake/sequence

rule gff2gtf:
    input:
        "output/{v}/collapse_{run}/{sample}.collapsed.{run}.{v}.gff"
    output:
        "output/{v}/collapse_{run}/{sample}.collapsed.{run}.{v}.gtf"
    log:
        "log/sqanti/{v}/{sample}_{run}_gff2gtf.log"
    shell:
        "gffread -T -o {output} {input}"

rule squanti_ref:
    input:
        annotation="input/annotations/{tool}/{sample}.{tool}-v2.3.gtf",
        genome="input/refs/{sample}.scaffolds-v2.3.fasta",
        isoforms="output/{v}/collapse_{run}/{sample}.collapsed.{run}.{v}.gtf"
    output:
        directory("output/{v}/collapse_{run}/{sample}_{tool}_sqanti/")
    params:
        prefix="{sample}-{run}-vs-{tool}",
        settings="--report both --skipORF"
    log:
        "log/sqanti/{v}/{run}/{sample}_{tool}_sqanti.log"
    shell:
        # "mkdir -p {output} && python3 /ebio/abt6/lvaness/software/SQANTI3-5.1/sqanti3_qc.py -o {params.prefix} --d {output} {input.isoforms} {input.annotation} {input.genome} |& tee {log}"
        "mkdir -p {output} && python3 /ebio/abt6/lvaness/software/SQANTI3-5.1/sqanti3_qc.py --report pdf -o {params.prefix} --d {output} {input.isoforms} {input.annotation} {input.genome} > {log}"

rule squanti_tama_ref:
    input:
        tama="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gtf",
        genome="input/refs/{sample}.scaffolds-v2.3.fasta",
        pb="output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gtf"
    output:
        directory("output/{v}/squanti_pb-vs-tama/{sample}/")
    params:
        prefix="{sample}-pb-vs-tama",
        settings="--report both --skipORF"
    log:
        "log/sqanti/{v}/pb-vs-tama/{sample}_pb-vs-tama_sqanti.log"
    shell:
        "mkdir -p {output} && python3 /ebio/abt6/lvaness/software/SQANTI3-5.1/sqanti3_qc.py -o {params.prefix} --d {output} {input.pb} {input.tama} {input.genome} |& tee {log}"

rule squanti_pb_ref:
    input:
        tama="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gtf",
        genome="input/refs/{sample}.scaffolds-v2.3.fasta",
        pb="output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gtf"
    output:
        directory("output/{v}/squanti_tama-vs-pb/{sample}/")
    params:
        prefix="{sample}-tama-vs-pb",
        settings="--report both --skipORF"
    log:
        "log/sqanti/{v}/tama-vs-pb/{sample}_tama-vs-pb_sqanti.log"
    shell:
        "mkdir -p {output} && python3 /ebio/abt6/lvaness/software/SQANTI3-5.1/sqanti3_qc.py -o {params.prefix} --d {output} {input.tama} {input.pb} {input.genome} |& tee {log}"


# rule squanti:
#     input:
#         annotation="/ebio/abt6_projects7/diffLines_20/annex/assembly-and-annotation/output/02_annotation/01_original-annotation-merged/{sample}.{tool}-v2.3.gff3",
#         genome="../input/refs/{sample}.scaffolds-v2.3.fasta",
#         isoforms="output/{v}/collapse_{run}/{sample}.collapsed.{run}.{v}.gtf"
#     output:
#         directory("output/{v}/collapse_{run}/{sample}_{tool}_sqanti/")
#     params:
#         prefix="{sample}-{run}-vs-{tool}"
#     # log:
#     shell:
#         "mkdir {output} && python3 /ebio/abt6/lvaness/software/SQANTI3-5.1/sqanti3_qc.py -o {params.prefix} -d {output} {input.isoforms} {input.annotation} {input.genome}"

