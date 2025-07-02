#!/bin/bash
# # Rename Difflines pfam gffs accoridng to ekg's PanSN naming
#
# We are using the [panSN naming scheme](https://github.com/pangenome/PanSN-spec) from ekg/pangenome team to rename all the 18 diff lines + Tair 10

mkdir -p output/02_annotation/03_pfam_original_augustus
#git annex unlock -q output/01_assembly/01_pansn-named

# The format we have settled on is: `${accession_id}_${haplotype}_${chr_or_contig}`. Ideally, we'd use a less common delimiter than `_` in these names, but very many programs break if we use other delimiters. A short history: `#` is a comment in gffs, `~` isn't valid in gffs, `:` would confuse the `chr1:1-233` range specfication, `!` doesn't play nice with bash due to history expansion, `|` is a pain on the CLI.
#
# The accession id is the ecotype id prefixed with at (so that they don't start with a number). The haplotype is either 1, as we have pseudo-haploid assemblies, or 9, indicating an unknown haplotype for unplaced contigs. Organellar genomes count as placed, and on the first haplotype.
# We have two different input naming schemes: the one from Max (Chr1_RagTag_RagTag) and the one from TAIR10. This first loop is for Max's genomes.

# +
dl20=(
at6137 at6923 at6929 at7143
at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806
at9830 at9847 at9852 at9879
at9883 at9900
)

for accession in "${dl20[@]}"
do
    gffsed=( sed
        -e "s/\bChr1_RagTag_RagTag\b/${accession}_1_chr1/g"
        -e "s/\bChr2_RagTag_RagTag\b/${accession}_1_chr2/g"
        -e "s/\bChr3_RagTag_RagTag\b/${accession}_1_chr3/g"
        -e "s/\bChr4_RagTag_RagTag\b/${accession}_1_chr4/g"
        -e "s/\bChr5_RagTag_RagTag\b/${accession}_1_chr5/g"
        -e "s/\bptg0\+\([0-9]\+\)[^\t0-9]*/${accession}_9_u\1/g"
    )
    
    "${gffsed[@]}" \
        ../manual_annotation/input/pfam_gffs/${accession}_pfam_genomic.gff \
        >output/02_annotation/03_pfam_original_augustus/${accession}_pfam_genomic-v2.3.gff
done
# -



