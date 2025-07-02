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

# # Full annotation pipeline from Max
#
# This is a parametric notebook (see next cell) which will annotate using Max's full annotation pipeline a given A. thaliana reference fasta file.

# + tags=["parameters"]
ACCESSION=at6137
SCAFFOLD_TITLE="unmasked"
SCAFFOLDS=01.assembly/03.masked/${ACCESSION}.scaffolds.${SCAFFOLD_TITLE}.fasta
NCPUS=${NSLOTS:-64}
REFERENCE_GENES_GFF=pansn_named/Araport.gff3
REFERENCE_SCAFFOLDS=pansn_named/Araport.scaffolds.fasta
# -

conda activate dl20-annotate

# # Step 1: liftoff
#
# This recreates max's `6_gene_annotation/2_liftoff/2_masked/run_liftoff.sh`. We use Araport.gff + Araport.scaffolds.fasta as the TAIR10 reference.

mkdir -p annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/
mkdir -p tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/

liftoff \
    -exclude_partial \
    -dir tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/ \
    -g $REFERENCE_GENES_GFF \
    -o annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/${ACCESSION}~${SCAFFOLD_TITLE}.liftoff.gff \
    -u annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/${ACCESSION}~${SCAFFOLD_TITLE}.unmapped.txt \
    -copies \
    -p $NCPUS \
    $SCAFFOLDS \
    $REFERENCE_SCAFFOLDS

awk 'BEGIN{FS=OFS="\t"}$3 == "exon" || $3 == "CDS"{print $1, $2, $3, $4, $5, $6, $7, $8, "source=T"}' \
    <annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/${ACCESSION}~${SCAFFOLD_TITLE}.liftoff.gff \
    >annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/${ACCESSION}~${SCAFFOLD_TITLE}.liftoff.hints

# + [markdown] tags=[]
# # Step 2: Augustus
#
# This is derived from `6_gene_annotation/4_augustus/2_annotation/runAugustus.sh`.
# -

# ## Step 2.1: Augustus annotation from inbuilt `arabidopsis` trained species dataset
#
# This runs augustus with `--species=arabidopsis`, i.e. the pre-trained weights the augutstus authors have trained on 

mkdir -p annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/

mkdir -p tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/01.seqsplit/
seqkit split -i -f -O tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/01.seqsplit/ $SCAFFOLDS

mkdir -p tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/02.spp-arabiopsis/
parallel -j $NCPUS augustus \
    --species=arabidopsis \
    --softmasking=1 \
    --hintsfile=annotation/${ACCESSION}~${SCAFFOLD_TITLE}/01.liftoff/${ACCESSION}~${SCAFFOLD_TITLE}.liftoff.hints \
    --extrinsicCfgFile=annotation/max-augustus-config_newtest.cfg \
    --gff3=on \
    {} \> tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/02.spp-arabiopsis/{/}.gff3 \
    ::: tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/01.seqsplit/*.fasta
cat tmp/annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/02.spp-arabiopsis/*.gff3  \
    >  annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/${ACCESSION}~${SCAFFOLD_TITLE}_augustus_spp-arabidopsis.gff3

# separate env as there are perl version incompatablities between augustus and AGAT
conda activate dl20-agat

ls annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/${ACCESSION}~${SCAFFOLD_TITLE}_augustus_spp-arabidopsis.gff3

awk '$0 !~ /^#/ && $3 =="gene" {print $0}'  annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/${ACCESSION}~${SCAFFOLD_TITLE}_augustus_spp-arabidopsis.gff3 | wc -l

agat_sp_statistics.pl --gff annotation/${ACCESSION}~${SCAFFOLD_TITLE}/02.augustus/${ACCESSION}~${SCAFFOLD_TITLE}_augustus_spp-arabidopsis.gff3

# ## Step 2.2: BUSCO retraining

mkdir -p annotation/${ACCESSION}/02.busco
rm -r tmp/annotation/${ACCESSION}/02.busco # TODO remove when this is all working properly
mkdir -p tmp/annotation/${ACCESSION}/02.busco

# cd into tmp dir as busco is daft and always outputs some files to $CWD
cd tmp/annotation/${ACCESSION}/02.busco
export NUMEXPR_MAX_THREADS=8  # fixes a bunch of stupid log messages
busco \
    --mode genome \
    --in ../../../../$SCAFFOLDS \
    --out busco_${ACCESSION}~${SCAFFOLD_TITLE}_embryophyta_odb10 \
    --lineage embryophyta_odb10 \
    --restart \
    --long --augustus_parameters='--progress=true' \
    --cpu $NCPUS
cd ../../../../
