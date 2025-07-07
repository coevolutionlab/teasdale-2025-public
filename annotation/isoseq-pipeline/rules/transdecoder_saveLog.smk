rule add_ID_tama:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.gtf"
    output:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.addID.gtf"
    log:
        "log/transdecoder/{v}/{sample}_ID_tama.log"
    shell:
        "python3 scripts/transdecoder_conversion.py -i {input} -o {output} |& tee {log}"

rule gtf2fasta_tama:
    input:
        gtf="output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.addID.gtf",
        fasta="input/refs/{sample}.scaffolds-v2.3.fasta"
    output:
        fasta="output/{v}/collapse_tama/{sample}_transdecoder/{sample}_transcripts.fasta",
        check=temp("output/{v}/collapse_tama/{sample}_transdecoder/fasta.done")
    log:
        "log/transdecoder/{v}/{sample}_tama.fasta.log"
    params:
        out=directory("output/{v}/collapse_tama/{sample}_transdecoder/")
    shell:
        "mkdir -p {params.out} && gtf_genome_to_cdna_fasta.pl {input.gtf} {input.fasta} > {output.fasta} |& tee {log} && touch {output.check}"

rule gtf2fasta_pb:
    input:
        gtf="output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gtf",
        fasta="input/refs/{sample}.scaffolds-v2.3.fasta"
    output:
        fasta="output/{v}/collapse_pb/{sample}_transdecoder/{sample}_transcripts.fasta",
        check=temp("output/{v}/collapse_pb/{sample}_transdecoder/fasta.done")
    log:
        "log/transdecoder/{v}/{sample}_pb.fasta.log"
    params:
        out=directory("output/{v}/collapse_pb/{sample}_transdecoder/")
    shell:
        "mkdir -p {params.out} && gtf_genome_to_cdna_fasta.pl {input.gtf} {input.fasta} > {output.fasta} |& tee {log} && touch {output.check}"

rule gtf2gff_tama:
    input:
        "output/{v}/collapse_tama/{sample}.collapsed.tama.{v}.addID.gtf"
    output:
        "output/{v}/collapse_tama/{sample}_transdecoder/{sample}_transcripts.gff3"
    log:
        "log/transdecoder/{v}/{sample}_tama.gff.log"
    params:
        path="output/{v}/collapse_tama/{sample}_transdecoder/"
    shell:
        "(gtf_to_alignment_gff3.pl {input} > {output}) > {log}"

rule gtf2gff_pb:
    input:
        "output/{v}/collapse_pb/{sample}.collapsed.pb.{v}.gtf"
    output:
        "output/{v}/collapse_pb/{sample}_transdecoder/{sample}_transcripts.gff3"
    log:
        "log/transdecoder/{v}/{sample}_pb.gff.log"
    params:
        path="output/{v}/collapse_ob/{sample}_transdecoder/"
    shell:
        "(gtf_to_alignment_gff3.pl {input} > {output}) > {log}"

rule longORF:
    input:
        check="output/{v}/collapse_{run}/{sample}_transdecoder/fasta.done"
    output:
        temp("output/{v}/collapse_{run}/{sample}_transdecoder/longORF.done")
    log:
        "log/transdecoder/{v}/{sample}_{run}.longORF.log"
    params:
        path="output/{v}/collapse_{run}/{sample}_transdecoder/",
        fasta="{sample}_transcripts.fasta"
    shell:
        """
        touch {input.check}
        cd {params.path}
        TransDecoder.LongOrfs -t {params.fasta} > ../../../../{log}
        cd ../../../../
        touch {output}
        """

rule predictORF:
    input:
        check="output/{v}/collapse_{run}/{sample}_transdecoder/longORF.done"
    output:
        temp("output/{v}/collapse_{run}/{sample}_transdecoder/Predict.done")
    log:
        "log/transdecoder/{v}/{sample}_{run}.predictORF.log"
    params:
        path="output/{v}/collapse_{run}/{sample}_transdecoder/",
        fasta="{sample}_transcripts.fasta"
    shell:
        """
        touch {input.check}
        cd {params.path}
        TransDecoder.Predict -t {params.fasta} > ../../../../{log}
        cd ../../../../
        touch {output}
        """

rule genome_anno:
    input:
        check="output/{v}/collapse_{run}/{sample}_transdecoder/Predict.done",
        gff3="output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.gff3",
        fasta="output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta"
    output:
        "output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.genome.gff3"
    log:
        "log/transdecoder/{v}/{sample}_{run}.genomeAnno.log"
    params:
        trans_gff="output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.gff3"
    shell:
        "(touch {input.check} && cdna_alignment_orf_to_genome_orf.pl {params.trans_gff} {input.gff3} {input.fasta} > {output}) |& tee {log}"

rule transdecoder_clean:
    input:
        "output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.genome.gff3"
    output:
        "output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.genome.cleaned.gff3"
    shell:
        "cat {input} | grep {wildcards.sample} > {output}"

rule transdecoder_sort:
    input:
        "output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.genome.cleaned.gff3"
    output:
        "output/{v}/collapse_{run}/{sample}_transdecoder/{sample}_transcripts.fasta.transdecoder.genome.sorted.gff3"
        # "/ebio/abt6_projects7/diffLines_20/data/Luisa_web_apollo/20230202_new_files_for_webapollo_v2/20230202_new_files_for_webapollo/transdecoder2/{sample}.{run}{v}_transcripts.fasta.transdecoder.genome.sorted.gff3"
    log:
        "log/transdecoder/{v}/{sample}_{run}.sort.log"
    shell:
        "agat_convert_sp_gxf2gxf.pl -g {input} -o {output} > {log}"
