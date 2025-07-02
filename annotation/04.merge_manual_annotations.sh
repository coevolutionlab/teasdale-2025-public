# ---
# jupyter:
#   jupytext:
#     formats: ipynb,sh:light
#     text_representation:
#       extension: .sh
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.0
#   kernelspec:
#     display_name: Bash
#     language: bash
#     name: bash
# ---

# # Step 4. Merge the fixed annotations

# Required input:
#
# - Original Augustus GFFs
# - GFFs with fixed gene annotations output from Webapollo
# - text file with missing gene models

conda activate dl20-annomerge

# 1. first merge the original GFFs with the gene models that were manually fixed

dl20=(
at6137 at6923 at6929 at7143
at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806
at9830 at9847 at9852 at9879
at9883 at9900
)

mkdir -p output/02_annotation/02_manual-curation-updated

# Only twelve accessions had NLR gene models which could be manually fixed without RNA evidence. The fixed gffs are per chromosome.

for accession in "${dl20[@]}"
do 
    mkdir -p "output/02_annotation/02_manual-curation-updated/${accession}"
    mkdir -p "tmp/02_annotation/02_manual-curation-updated/"

    if [ ! -d "input/luisa_manual_annotation_updates/2022-07-28/${accession}" ]
    then
        cp "output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3" \
            "output/02_annotation/02_manual-curation-updated/${accession}/${accession}.manualcuration.gff3"
        continue
    fi

    zcat "input/luisa_manual_annotation_updates/2022-07-29/${accession}"*.gff3.gz \
        >"tmp/02_annotation/02_manual-curation-updated/${accession}.everything.gff3"

    gffsed=( sed
        -e "s/\bChr1_RagTag_RagTag\b/${accession}_1_chr1/g"
        -e "s/\bChr2_RagTag_RagTag\b/${accession}_1_chr2/g"
        -e "s/\bChr3_RagTag_RagTag\b/${accession}_1_chr3/g"
        -e "s/\bChr4_RagTag_RagTag\b/${accession}_1_chr4/g"
        -e "s/\bChr5_RagTag_RagTag\b/${accession}_1_chr5/g"
        -e "s/\bptg0\+\([0-9]\+\)[^\t0-9]*/${accession}_9_u\1/g"
    )

    "${gffsed[@]}" \
        < "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.gff3" \
        > "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3"


    echo -n "$accession has fixes for this many genes: "
    awk '$3 == "gene"{print}' \
        "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3" \
        | wc -l

    gff3_QC \
        -f "output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta" \
        -g "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3" \
        -o "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3.qcreport.txt" \
        -s "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3.statistic.txt"


    gff3_fix \
        -g "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3" \
        -og "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.fixed.gff3" \
        -qc_r "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.gff3.qcreport.txt"

    gff3_QC \
        -f "output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta" \
        -g "output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3"  \
        -o "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.qcreport.txt" \
        -s "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.statistic.txt" \
        > "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.check.log" 2>&1

    gff3_fix \
        -g "output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3" \
        -og "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.fixed.gff3" \
        -qc_r "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.qcreport.txt" \
        > "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.fix.log" 2>&1

    gff3_merge \
        -f "output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta" \
        -g1 "tmp/02_annotation/02_manual-curation-updated/${accession}.everything.pansn.fixed.gff3" \
        -g2 "output/02_annotation/01_original-annotation-merged/${accession}.augustus-v2.3.gff3" \
        -og "output/02_annotation/02_manual-curation-updated/${accession}/${accession}.manualcuration.gff3" \
        -r "output/02_annotation/02_manual-curation-updated/${accession}/${accession}.manualcuration.mergereport.txt" \
        > "tmp/02_annotation/02_manual-curation-updated/${accession}.augustus.gff3.merge.log" 2>&1

    gt gff3 -sort -tidy -retainids -force \
        -o "output/02_annotation/02_manual-curation-updated/${accession}/${accession}.manualcuration.fixed.gff3"  \
        "output/02_annotation/02_manual-curation-updated/${accession}/${accession}.manualcuration.gff3"
done

# +
for sample in $(cat fixed_accession_names.txt)
do
    gff3_QC -f input/scaffolds/${sample}.scaffolds.bionano.final.fasta -g output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_combined.gff -o output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_report.txt
    gff3_fix -qc_r output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_report.txt -g output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_combined.gff -og output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_combined_fixed.gff

    gff3_QC -f input/scaffolds/${sample}.scaffolds.bionano.final.fasta -g input/augustus_gff/${sample}.softmasked.final.gff3 -o tmp/${sample}.softmasked.final.report
    gff3_fix -qc_r tmp/${sample}.softmasked.final.report -g input/augustus_gff/${sample}.softmasked.final.gff3 -og tmp/${sample}.softmasked.final_fixed.gff3

    gff3_merge -g1 output/GFFs_with_only_the_fixed_annotations/${sample}/${sample}_combined_fixed.gff -g2 tmp/${sample}.softmasked.final_fixed.gff3 -f input/scaffolds/${sample}.scaffolds.bionano.final.fasta -og output/fixed_annotations_merged_with_augustus_annotations/${sample}.softmasked.final_fixed_20220726.gff3 -r output/fixed_annotations_merged_with_augustus_annotations/${sample}_merge_report.txt

done
# -

head input/augustus_gff/${sample}.softmasked.final.gff3 -n 100

# 2. Add the gene models that were orginally left out of the NLR orthogroups but were identified during the manual annotation.
