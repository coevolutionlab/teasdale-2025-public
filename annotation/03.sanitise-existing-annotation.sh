# ---
# jupyter:
#   jupytext:
#     formats: ipynb,sh:light
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

dl20=(
at6137 at6923 at6929 at7143 at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806 at9830 at9847 at9852 at9879
at9883 at9900
)
mkdir -p output/02_annotation/01_original-annotation-merged
mkdir -p tmp/02_annotation/01_original-annotation-merged
conda activate dl20-gff

# +
for accession in "${dl20[@]}"
do

    echo "preprep TEs for $accession"
    grep "^$accession" input/2022-07-16_curated-repeat-annotation-adri/pangenome.fasta.mod.EDTA.TEanno.gff3 | \
    ./src/pansn-rename -R '_' -d '#' -D '_' -m cat \
        -r output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta.fai \
        -o tmp/02_annotation/01_original-annotation-merged/${accession}_all-repeats.gff3 \
        -

    # Genomtools outputs a *lot* of bullshit logging, which will crash jupyter as it's actually longer
    # than the original gffs. So, we save the log files alongside the outputs, in case they are ever useful.

    ( ./src/liftoff-gff3 \
        < tmp/02_annotation/01_original-annotation-merged/${accession}_all-repeats.gff3 \
    | gt gff3 -sort -tidy -retainids -force \
        -o output/02_annotation/01_original-annotation-merged/${accession}.all-repeats.gff3 \
    && echo "done gt repeats for $accession" \
    ) |& tee output/02_annotation/01_original-annotation-merged/${accession}.all-repeats.gff3.log | \
    grep -vi '^warning' || true

    ( ./src/liftoff-gff3 \
        < output/01_assembly/01_pansn-named/${accession}.augustus-v2.3.gff3 \
    | gt gff3 -sort -tidy -retainids -force \
        -o output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3 \
    &&  echo "done gt augustus for $accession" \
    ) |& tee output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3.log | \
    grep -vi '^warning'

    ( ./src/liftoff-gff3 \
        < output/01_assembly/01_pansn-named/${accession}.liftoff-v2.3.gff \
    | gt gff3 -sort -tidy -retainids -force \
        -o output/02_annotation/01_original-annotation-merged/${accession}.liftoff-v2.3.gff3 \
    && echo "done gt liftoff for $accession" \
    ) |& tee output/02_annotation/01_original-annotation-merged/${accession}.liftoff-v2.3.gff3.log | \
    grep -vi '^warning' || true

    # The nlrparser output is a special one in that it isn't *really* a gff.
    # It's a bed with an extra column that kinda works as a gff if you squint.
    # So, just make it a bed. It's a gff enough to used 1-based coordinates though
    # so fix that up.

    awk 'BEGIN{FS=OFS="\t"}{print $1, $3-1, $4, $5, $6}' \
        < output/01_assembly/01_pansn-named/${accession}.nlrparser-completeNLRs-v2.3.gff \
        > output/02_annotation/01_original-annotation-merged/${accession}.nlrparser-completeNLRs-v2.3.bed

    ( ./src/liftoff-gff3 \
        < output/01_assembly/01_pansn-named/${accession}.nlrome-liftoff-v2.3.gff \
    | gt gff3 -sort -tidy -retainids -force \
        -o output/02_annotation/01_original-annotation-merged/${accession}.nlrome-liftoff-v2.3.gff3 \
    && echo "done gt nlrome for $accession" \
    ) |& tee output/02_annotation/01_original-annotation-merged/${accession}.nlrome-liftoff-v2.3.gff3.log | \
    grep -vi '^warning'

done
# -

