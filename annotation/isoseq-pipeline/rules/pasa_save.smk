rule generate_iso_fasta_tama:
    input:
        genome="input/refs/{sample}.scaffolds-v2.3.fasta",
        gff="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gff3"
    output:
        fasta="output/{v}/collapse_tama/{sample}_augustus_pasa/{sample}.collapsed.tama.{v}.fasta"
    log:
        "log/pasa/{v}/tama/{sample}_iso2fasta.log"
    params:
        dir=directory("output/{v}/collapse_tama/{sample}_augustus_pasa/")
    priority: 100
    shell:
        "mkdir -p {params.dir} && gffread -w {output.fasta} -g {input.genome} {input.gff} > {log}"

rule generate_iso_fasta_pb:
    input:
        genome="input/refs/{sample}.scaffolds-v2.3.fasta",
        gff="output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gff"
    output:
        fasta="output/{v}/collapse_pb/{sample}_augustus_pasa/{sample}.collapsed.pb.{v}.fasta"
    log:
        "log/pasa/{v}/pb/{sample}_iso2fasta.log"
    params:
        dir=directory("output/{v}/collapse_tama/{sample}_augustus_pasa/")
    priority: 100
    shell:
        "mkdir -p {params.dir} && gffread -w {output.fasta} -g {input.genome} {input.gff} > {log}"

rule seqclean:
    input:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/{sample}.collapsed.{run}.{v}.fasta"
    output:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/seqclean.done"
    log:
        "/ebio/abt6_projects7/dliso/dlis/leon_pipeline/log/pasa/{v}/{run}/{sample}_seqclean.log"
    params:
        dir=directory("output/{v}/collapse_{run}/{sample}_augustus_pasa/"),
        input="{sample}.collapsed.{run}.{v}.fasta"
    threads: 10
    priority: 90
    shell:
        """
        touch {input}
        cd {params.dir}
        pwd
        ~/software/PASApipeline/bin/seqclean {params.input} -c {threads} > {log}
        cd ../../../../
        touch {output}
        """

rule config_align:
    input:
        "/ebio/abt6/lvaness/software/PASApipeline/pasa_conf/pasa.alignAssembly.Template.txt"
    output:
        cfg="output/{v}/collapse_{run}/{sample}_augustus_pasa/alignAssembly.config",
        check="output/{v}/collapse_{run}/{sample}_augustus_pasa/alignAssembly.done"
    params:
        path="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/output/{v}/collapse_{run}/{sample}_augustus_pasa/{sample}_mydb_pasa"
    priority: 80
    shell:
        """
        cp {input} {output.cfg}
        sed -i \"s@<__DATABASE__>@{params.path}@\" {output.cfg}
        touch {output.check}
        """

rule set_params:
    input:
        "/ebio/abt6/lvaness/software/PASApipeline/pasa_conf/pasa.annotationCompare.Template.txt"
    output:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.config"
    params:
        ov="30",
        rp="40",
        pp="70",
        fl="30",
        nfl="30",
        pa="30",
        pog="30",
        ue="2"
    priority: 75
    shell:
        "python3 scripts/pasa_config.py -i {input} -o {output} -ov {params.ov} -rp {params.rp} -pp {params.pp} -fl {params.fl} -nfl {params.nfl} -pa {params.pa} -pog {params.pog} -ue {params.ue}"

rule config_anno:
    input:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.config"
    output:
        check="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.done"
    params:
        path="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/output/{v}/collapse_{run}/{sample}_augustus_pasa/{sample}_mydb_pasa",
        file="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.config"
    priority: 80
    shell:
        """
        sed -i \"s@<__DATABASE__>@{params.path}@\" {params.file}
        touch {output.check}
        """

#rule config_anno:
#    input:
#        "/ebio/abt6/lvaness/software/PASApipeline/pasa_conf/pasa.annotationCompare.Template.txt"
#    output:
#        cfg="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.config",
#        check="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.done"
#    params:
#        path="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/output/{v}/collapse_{run}/{sample}_augustus_pasa/{sample}_mydb_pasa"
#    priority: 80
#    shell:
#        """
#        cp {input} {output.cfg}
#        sed -i \"s@<__DATABASE__>@{params.path}@\" {output.cfg}
#        touch {output.check}
#        """

rule pasa_alignment_tama:
    """
    run this prior to pasa_alignment_pb, since parallel indexing causes trouble
    """
    input:
        seqclean="output/{v}/collapse_tama/{sample}_augustus_pasa/seqclean.done",
        cfg="output/{v}/collapse_tama/{sample}_augustus_pasa/alignAssembly.done"
    output:
        check="output/{v}/collapse_tama/{sample}_augustus_pasa/alignment.done",
        idx_check="output/{v}/collapse_tama/{sample}_augustus_pasa/idx_check.done"
    log:
        "/ebio/abt6_projects7/dliso/dlis/leon_pipeline/log/pasa/{v}/tama/{sample}_alignment.log"
    params:
        dir="output/{v}/collapse_tama/{sample}_augustus_pasa/",
        config="alignAssembly.config",
        genome="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/input/refs/{sample}.scaffolds-v2.3.fasta",
        fasta="{sample}.collapsed.tama.{v}.fasta",
        fasta_clean="{sample}.collapsed.tama.{v}.fasta.clean",
        aligners="blat,gmap,minimap2"
    threads: 30
    priority: 70
    shell:
        """
        touch {input.seqclean}
        touch {input.cfg}
        cd {params.dir}
        ~/software/PASApipeline/Launch_PASA_pipeline.pl -c {params.config} -C -R -g {params.genome} -t {params.fasta_clean} -T -u {params.fasta} --ALIGNERS {params.aligners} --CPU {threads} |& tee {log}
        cd ../../../../
        touch {output.check}
        touch {output.idx_check}
        """

rule pasa_alignment_pb:
    input:
        seqclean="output/{v}/collapse_pb/{sample}_augustus_pasa/seqclean.done",
        cfg="output/{v}/collapse_pb/{sample}_augustus_pasa/alignAssembly.done",
        idx_check="output/{v}/collapse_tama/{sample}_augustus_pasa/idx_check.done"
    output:
        "output/{v}/collapse_pb/{sample}_augustus_pasa/alignment.done"
    log:
        "/ebio/abt6_projects7/dliso/dlis/leon_pipeline/log/pasa/{v}/pb/{sample}_alignment.log"
    params:
        dir="output/{v}/collapse_pb/{sample}_augustus_pasa/",
        config="alignAssembly.config",
        genome="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/input/refs/{sample}.scaffolds-v2.3.fasta",
        fasta="{sample}.collapsed.pb.{v}.fasta",
        fasta_clean="{sample}.collapsed.pb.{v}.fasta.clean",
        aligners="blat,gmap,minimap2"
    threads: 30
    priority: 65
    shell:
        """
        touch {input.seqclean}
        touch {input.cfg}
        touch {input.idx_check}
        cd {params.dir}
        ~/software/PASApipeline/Launch_PASA_pipeline.pl -c {params.config} -C -R -g {params.genome} -t {params.fasta_clean} -T -u {params.fasta} --ALIGNERS {params.aligners} --CPU {threads} |& tee {log}
        cd ../../../../
        touch {output}
        """


rule pasa_load_anno1:
    input:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/alignment.done"
    output:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/load1.done"
    log:
        "/ebio/abt6_projects7/dliso/dlis/leon_pipeline/log/pasa/{v}/{run}/{sample}_loadAnno1.log"
    params:
        dir="output/{v}/collapse_{run}/{sample}_augustus_pasa/",
        config="alignAssembly.config",
        genome="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/input/refs/{sample}.scaffolds-v2.3.fasta",
        anno2update="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/input/annotations/augustus/{sample}.augustus-v2.3.gff3"
    priority: 60
    shell:
        """
        touch {input}
        cd {params.dir}
        ~/software/PASApipeline/scripts/Load_Current_Gene_Annotations.dbi -c {params.config} -g {params.genome} -P {params.anno2update} |& tee {log}
        cd ../../../../
        touch {output}
        """

rule pasa_compare_anno1:
    input:
        loading="output/{v}/collapse_{run}/{sample}_augustus_pasa/load1.done",
        cfg="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.done"
    output:
        "output/{v}/collapse_{run}/{sample}_augustus_pasa/compare1.done"
    log:
        "/ebio/abt6_projects7/dliso/dlis/leon_pipeline/log/pasa/{v}/{run}/{sample}_compAnno1.log"
    params:
        dir="output/{v}/collapse_{run}/{sample}_augustus_pasa/",
        config="annotCompare.config",
        genome="/ebio/abt6_projects7/dliso/dlis/leon_pipeline/input/refs/{sample}.scaffolds-v2.3.fasta",
        fasta_clean="{sample}.collapsed.{run}.{v}.fasta.clean"
    threads: 30
    priority: 50
    shell:
        """
        touch {input.loading}
        touch {input.cfg}
        cd {params.dir}
        ~/software/PASApipeline/Launch_PASA_pipeline.pl -c {params.config} -A -g {params.genome} -t {params.fasta_clean} --CPU {threads} |& tee {log}
        cd ../../../../
        touch {output}
        """

# rule pasa_load_anno2:
#     input:
#         check="output/{v}/collapse_{run}/{sample}_augustus_pasa/compare1.done",
#         config="output/{v}/collapse_{run}/{sample}_augustus_pasa/alignAssembly.config",
#         genome="input/refs/{sample}.scaffolds-v2.3.fasta"
#     output:
#         "output/{v}/collapse_{run}/{sample}_augustus_pasa/alignment2.done"
#     log:
#         "log/pasa/{v}/{run}/{sample}_loadAnno2.log"
#     params:
#         anno2update="input/annotations/augustus/{sample}_mydb_pasa.gene_structures_post_PASA_updates.*.gff3"
#     priority: 40
#     shell:
#         "touch {input.check} && ~/software/PASApipeline/scripts/Load_Current_Gene_Annotations.dbi -c {input.config} -g {input.genome} -P {params.anno2update} |& tee {log}"
# 
# rule pasa_compare_anno2:
#     input:
#         check="output/{v}/collapse_{run}/{sample}_augustus_pasa/alignment2.done",
#         config="output/{v}/collapse_{run}/{sample}_augustus_pasa/annotCompare.config",
#         genome="input/refs/{sample}.scaffolds-v2.3.fasta",
#         fasta_clean="output/{v}/collapse_{run}/{sample}_augustus_pasa/{sample}.collapsed.{run}.{v}.fasta.clean"
#     output:
#         "../../../../output/{v}/collapse_{run}/{sample}_augustus_pasa/compare2.done"
#     log:
#         "log/pasa/{v}/{run}/{sample}_compAnno2.log"
#     params:
#         threads=30
#     priority: 30
#     shell:
#         "touch {input.check} && ~/software/PASApipeline/Launch_PASA_pipeline.pl -c {input.config} -A -g {input.genome} -t {input.fasta_clean} --CPU {params.threads} |& tee {log} && touch {output}"
