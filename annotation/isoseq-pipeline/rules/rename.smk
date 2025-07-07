for bc, sample in zip(rename_in, rename_out):
    rule:
        input:
            f"output/lima/{bc}/"
        output:
            f"output/lima/{sample}/"
        shell:
            "mv {input} {output}"
