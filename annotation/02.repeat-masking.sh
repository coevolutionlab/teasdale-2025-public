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

# # Un-mask softmasked genomes

conda activate dl20
mkdir -p output/01_assembly/02_masked
mkdir -p tmp/01_assembly/02_masked/
git annex unlock -q output/01_assembly/02_masked

# In the following, we:
#
# 1. completely unmask Max's original scaffolds (with panSN names)
# 2. for each of the three levels of repeat masking, we
#     1. get this accessions entries out of Adri's big gff, then rename the PanSN names to use `_`
#     2. mask the fasta with this new renamed gff
#     3. faidx the resulting fasta

dl20=(
at6137 at6923 at6929 at7143 at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806 at9830 at9847 at9852 at9879
at9883 at9900
)
for accession in "${dl20[@]}"
do
    # UNMAKSED
    seqtk seq -U -S output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta \
        > output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta
    samtools faidx output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta
    
    
    # Adri's EVERYTHING
    grep "^$accession" input/2022-07-16_curated-repeat-annotation-adri/pangenome.fasta.mod.EDTA.TEanno.gff3 | \
    ./src/pansn-rename -R '_' -d '#' -D '_' -m cat \
        -r output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta.fai \
        -o tmp/01_assembly/02_masked/${accession}_all-repeats.gff3 \
        -
    bedtools maskfasta \
        -fi output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta \
        -fo output/01_assembly/02_masked/${accession}.scaffolds.all-repeats-masked.fasta \
        -bed tmp/01_assembly/02_masked/${accession}_all-repeats.gff3 \
        -soft -fullHeader
    samtools faidx output/01_assembly/02_masked/${accession}.scaffolds.all-repeats-masked.fasta
    
    
    # TELOMERES, CENTROMERES, AND RDNAS
    grep "^$accession" input/2022-07-16_curated-repeat-annotation-adri/telomeres_centromeres_rDNAs.gff3 | \
    ./src/pansn-rename -R '_' -d '#' -D '_' -m cat \
        -r output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta.fai \
        -o tmp/01_assembly/02_masked/${accession}_telo-centro-rdna.gff3 \
        -
    bedtools maskfasta \
        -fi output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta \
        -fo output/01_assembly/02_masked/${accession}.scaffolds.telo-centro-rdna-masked.fasta \
        -bed tmp/01_assembly/02_masked/${accession}_telo-centro-rdna.gff3 \
        -soft -fullHeader
    samtools faidx output/01_assembly/02_masked/${accession}.scaffolds.telo-centro-rdna-masked.fasta
    
    # Adri's REDUCED, "HIGH CONFIDENCE" TE ANNOTATION
    grep "^$accession" input/2022-07-16_curated-repeat-annotation-adri/reduced_TE_anno.gff3 | \
    ./src/pansn-rename -R '_' -d '#' -D '_' -m cat \
        -r output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta.fai \
        -o tmp/01_assembly/02_masked/${accession}_reduced-te.gff3 \
        -
    bedtools maskfasta \
        -fi output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta \
        -fo output/01_assembly/02_masked/${accession}.scaffolds.reduced-te-masked.fasta \
        -bed tmp/01_assembly/02_masked/${accession}_reduced-te.gff3 \
        -soft -fullHeader
    samtools faidx output/01_assembly/02_masked/${accession}.scaffolds.reduced-te-masked.fasta
    
    echo "done $accession"
done

# ## Sanity checking
#
# The following files should have been soft-masked, and I do them in what should be the most masked -> least masked. we're counting lines in a bed file of masked regions, i.e. the number of masked features. In case you're re-running this, the numbers now are 36949, 5732, 658, and 0.

blsl mask2bed output/01_assembly/02_masked/${accession}.scaffolds.all-repeats-masked.fasta | wc -l

blsl mask2bed output/01_assembly/02_masked/${accession}.scaffolds.reduced-te-masked.fasta  | wc -l

blsl mask2bed output/01_assembly/02_masked/${accession}.scaffolds.telo-centro-rdna-masked.fasta  | wc -l

blsl mask2bed output/01_assembly/02_masked/${accession}.scaffolds.unmasked.fasta | wc -l
