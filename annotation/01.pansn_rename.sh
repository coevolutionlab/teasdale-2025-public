#!/bin/bash
# # Rename Difflines contigs accoridng to ekg's PanSN naming
#
# We are using the [panSN naming scheme](https://github.com/pangenome/PanSN-spec) from ekg/pangenome team to rename all the 18 diff lines + Tair 10

mkdir -p output/01_assembly/01_pansn-named
git annex unlock -q output/01_assembly/01_pansn-named

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
    sed \
        -e "s/^>\bChr1_RagTag_RagTag\b/>${accession}_1_chr1/g" \
        -e "s/^>\bChr2_RagTag_RagTag\b/>${accession}_1_chr2/g" \
        -e "s/^>\bChr3_RagTag_RagTag\b/>${accession}_1_chr3/g" \
        -e "s/^>\bChr4_RagTag_RagTag\b/>${accession}_1_chr4/g" \
        -e "s/^>\bChr5_RagTag_RagTag\b/>${accession}_1_chr5/g" \
        -e "s/^>\bptg0\+\([0-9]\+\)[^\t0-9]*/>${accession}_9_u\1/g" \
        input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/1_assemblies/${accession}.scaffolds.bionano.final.fasta \
        >output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta
    
    diff input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/1_assemblies/${accession}.scaffolds.bionano.final.fasta \
        output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta  || true # diff exits non-zero if it finds differences
        
    samtools faidx output/01_assembly/01_pansn-named/${accession}.scaffolds-v2.3.fasta  || true # diff exits non-zero if it finds differences


    gffsed=( sed
        -e "s/\bChr1_RagTag_RagTag\b/${accession}_1_chr1/g"
        -e "s/\bChr2_RagTag_RagTag\b/${accession}_1_chr2/g"
        -e "s/\bChr3_RagTag_RagTag\b/${accession}_1_chr3/g"
        -e "s/\bChr4_RagTag_RagTag\b/${accession}_1_chr4/g"
        -e "s/\bChr5_RagTag_RagTag\b/${accession}_1_chr5/g"
        -e "s/\bptg0\+\([0-9]\+\)[^\t0-9]*/${accession}_9_u\1/g"
    )
    
    "${gffsed[@]}" \
        input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/2_annotation/1_geneAnnotation/2_augustus/${accession}.softmasked.final.gff3 \
        >output/01_assembly/01_pansn-named/${accession}.augustus-v2.3.gff3
    
    "${gffsed[@]}" \
        input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/2_annotation/1_geneAnnotation/1_liftoff/${accession}.liftoff.gff \
        >output/01_assembly/01_pansn-named/${accession}.liftoff-v2.3.gff
    
    "${gffsed[@]}" \
        input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/2_annotation/2_nlrAnnotation/2_nlrParser/${accession}.completeNLRs.gff \
        >output/01_assembly/01_pansn-named/${accession}.nlrparser-completeNLRs-v2.3.gff
    
    "${gffsed[@]}" \
        input/max-v2.3-data-freeze/2.3_data_freeze_hifiasm/2_annotation/2_nlrAnnotation/1_NLRome/${accession}.nlr.liftoff.gff \
        >output/01_assembly/01_pansn-named/${accession}.nlrome-liftoff-v2.3.gff
done
# -


# And these two are for TAIR10, which uses a different naming scheme, and so we need to use different regex.

sed \
    -e "s/^>\bChr1\b.\+/>tair10_1_chr1/g" \
    -e "s/^>\bChr2\b.\+/>tair10_1_chr2/g" \
    -e "s/^>\bChr3\b.\+/>tair10_1_chr3/g" \
    -e "s/^>\bChr4\b.\+/>tair10_1_chr4/g" \
    -e "s/^>\bChr5\b.\+/>tair10_1_chr5/g" \
    -e "s/^>\bChrC\b.\+/>tair10_1_chrC/g" \
    -e "s/^>\bChrM\b.\+/>tair10_1_chrM/g" \
    input/max-v2.3-data-freeze/Araport.fasta \
    >output/01_assembly/01_pansn-named/Araport.scaffolds.fasta
samtools faidx output/01_assembly/01_pansn-named/Araport.scaffolds.fasta


sed \
    -e "s/^Chr1\b/tair10_1_chr1/g" \
    -e "s/^Chr2\b/tair10_1_chr2/g" \
    -e "s/^Chr3\b/tair10_1_chr3/g" \
    -e "s/^Chr4\b/tair10_1_chr4/g" \
    -e "s/^Chr5\b/tair10_1_chr5/g" \
    -e "s/^ChrC\b/tair10_1_chrC/g" \
    -e "s/^ChrM\b/tair10_1_chrM/g" \
    input/max-v2.3-data-freeze/Araport.gff3 \
    >output/01_assembly/01_pansn-named/Araport.gff3

# Now we need to check the differences between the inputs and renamed copied. We just use diff, as the only things that change should be the header.
