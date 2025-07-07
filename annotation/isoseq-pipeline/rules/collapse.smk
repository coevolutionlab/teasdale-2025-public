rule collapse_pb_strict:
    input:
        "output/mapping_pb/{sample}.mapped.bam"
    output:
        "output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gff"
    log:
        "log/collapse_pb/{sample}.collapse.{v}.log"
    threads: 4
    params:
        v=config["pb_c"]
    shell:
        "mkdir -p output/{v}/collapse_pb && isoseq3 collapse --do-not-collapse-extra-5exons {params.v} --log-level INFO --log-file {log} -j {threads} {input} {output}"

rule collapse_stringtie_strict:
    input:
        "output/mapping_minimap/{sample}.mapped.bam"
    output:
        "output/{v}/collapse_stringtie/{sample}.collapsed.stringtie.{v}.gff"
    log:
        "log/collapse_stringtie/{sample}.collapsed.{v}.log"
    params:
        v=config["stringtie_c"]
    shell:
        "mkdir -p output/{v}/collapse_stringtie && ~/software/stringtie/stringtie {params.v} -o {output} {input} |& tee {log}"

rule collapse_tama_strict:
    input:
        mapping="output/mapping_minimap/{sample}.mapped.bam",
        fasta="input/refs/{sample}.scaffolds-v2.3.fasta"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.bed"
    log:
        "log/collapse_tama/{sample}.collapse.{v}.log"
    params:
        python_path="~/anaconda3/envs/py2.7/bin/python2.7",
        tama_path="~/software/tama/tama_collapse.py",
        prefix="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}",
        v=config["tama_c"]
    conda:
        "envs/tama.yaml"
    shell:
        "mkdir -p output/{v}/collapse_tama && {params.python_path} {params.tama_path} -s {input.mapping} -b BAM -f {input.fasta} -p {params.prefix} {params.v} -log log_off |& tee {log}"
        # "mkdir -p output/{v}/collapse_tama && python2.7 {params.tama_path} -s {input.mapping} -b BAM -f {input.fasta} -p {params.prefix} {params.v} -log log_off |& tee {log}"

rule bed2gtf_strict:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.bed"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gtf"
    log:
        "log/bed2gtf/{sample}.collapsed.tama.{v}.gtf.log"
    shell:
        "perl scripts/bed12ToGTF.1.pl < {input} > {output} |& tee {log}"

rule gtf2gff3_strict:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gtf"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gff3"
    log:
        "log/gtf2gff3/{sample}.collapsed.tama.{v}.gff3.log"
    shell:
        "gffread -E --keep-genes {input} -o {output} |& tee {log}"

######### TAMA read support #########
rule tama_file_list:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gff3"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.reads.txt"
    shell:
        """
        touch {input}
        echo -e 'flnc\toutput/{wildcards.v}/collapse_tama/{wildcards.sample}.collapsed.tama.{wildcards.v}_trans_read.bed\ttrans_read' > {output}
        """

rule read_support_tama:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.reads.txt"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}_read_support.txt"
    params:
        tama_path="~/software/tama/tama_go/read_support/tama_read_support_levels.py",
        prefix="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}"
    shell:
        "python {params.tama_path} -f {input} -o {params.prefix} -m no_merge"
#####################################

rule merge:
    input:
        pb="output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gff",
        stringtie="output/{v}/collapse_stringtie/{sample}.collapsed.stringtie.{v}.gff",
        tama="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gff3"
    output:
        "output/{v}/merged_gff/{sample}.merged.gff"
    log:
        "log/merged_gff/{sample}.merged.{v}.log"
    shell:
        "mkdir -p output/{v}/merged_gff && stringtie --merge -o {output} {input} |& tee {log}"
