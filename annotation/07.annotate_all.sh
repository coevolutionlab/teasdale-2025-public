# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .sh
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.13.8
#   kernelspec:
#     display_name: Bash
#     language: bash
#     name: bash
# ---

# # annotate-all

dl20=(
at6137 at6923 at6929 at7143
at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806
at9830 at9847 at9852 at9879
at9883 at9900
)
mkdir -p tmp/log

# +
for accession in "${dl20[@]}"
do
    for masking in all-repeats-masked reduced-te-masked telo-centro-rdna-masked unmasked
    do
        OUT="output/02_annotation/03_augustus-reannotation/${accession}~${masking}/"
        mkdir -p $OUT
        
        if [ -e $OUT/02_augustus/${accession}~${masking}_augustus_spp-arabidopsis.gff3 ]
        then
            echo "SKIP    ${accession}_${masking}"
            continue
        fi
        
        echo "SUB     ${accession}_${masking}"
        qsub -N an_${accession}_${masking}  \
            -o tmp/log/ \
            -pe parallel 8 \
            -l h_vmem=6G \
            -l h_rt=18:00:00 \
            -j y \
            -S /bin/bash \
            -cwd \
            -m beas   <<EOF
        source ~/.bashrc;
        export PATH="$HOME/.local/bin:$PATH"
        papermill \
            --request-save-on-cell-execute \
            --autosave-cell-every 60 \
            -p ACCESSION "$accession" \
            -p SCAFFOLD_TITLE "${masking}" \
            -p SCAFFOLDS "output/01_assembly/02_masked/${accession}.scaffolds.${masking}.fasta" \
            -p OUTDIR "${OUT}" \
            do_annotate_full_per_fasta.ipynb \
            "${OUT}/annotation_output.ipynb"
            
EOF
    done
done
# -


