# USAGE:  # ./script_ragtag.sh <CONTIGS> <ACC> <CORES>

# EXAMPLE  # ./script_ragtag.sh /tmp/global2/frabanal/Ath_centromeres_18diffLines/data/2_hifiasm/CAMA-C-2/CAMA-C-2.p_ctg.fa CAMA-C-2 8

# Parse parameteres
CONTIGS=$1
ACC=$2
CORES=$3

# Declare other variables
REF=/tmp/global2/frabanal/Ath_centromeres_18diffLines/code/TAIR10.hard_masked.fa
CUTOFF=100000
cutoff=$(( CUTOFF / 1000 ))kb
Q=60
LENGTH=30000
GROUPING=0.5
NAME=masked_"$cutoff"_q"$Q"_f"$LENGTH"_i"$GROUPING"

WORKTMP=/tmp/global2/frabanal/Ath_centromeres_18diffLines/data

outputTMP=$WORKTMP/3_ragtag/$ACC

# Create necessary directories
mkdir -p $output
mkdir -p $outputTMP

# Activate virtual environment
source activate /ebio/abt6_projects8/alopecurus_genome/bin/anaconda2/envs/RagTag_v2.0.1
SAMTOOLS=/ebio/abt6_projects9/abt6_software/bin/samtools-1.9/bin/samtools
ASSEMBLY=/ebio/abt6_projects8/alopecurus_genome/bin/assembly-stats-master/bin

# Start
echo ""
echo "Start script"
date

##############################################
################### RagTag ################### 
echo "Soft link CONTIGS..."
rsync -av $CONTIGS $outputTMP/$ACC.contigs.fa

echo "Filtering CONTIGS by size..."
perl $PWD/keep_SMALL_contigs.pl $CUTOFF $outputTMP/$ACC.contigs.fa > $outputTMP/$ACC.contigs.SMALL.$cutoff.fa
perl $PWD/keep_LARGE_contigs.pl $CUTOFF $outputTMP/$ACC.contigs.fa > $outputTMP/$ACC.contigs.LARGE.$cutoff.fa

echo "Scaffolding MASKED..."
cd $outputTMP
rm -rf ragtag_output

ragtag.py scaffold $REF $outputTMP/$ACC.contigs.LARGE.$cutoff.fa \
	-t $CORES \
	-q $Q -f $LENGTH -i $GROUPING \
	--remove-small

mv $outputTMP/ragtag_output/ragtag.scaffold.fasta $outputTMP/$ACC.ragtag_scaffolds.$cutoff.fa
sed -i "s/_RagTag//g" $outputTMP/$ACC.ragtag_scaffolds.$cutoff.fa

mv $outputTMP/ragtag_output/ragtag.scaffold.stats $outputTMP/$ACC.ragtag_scaffolds.$cutoff.stats

echo "Creating joint file for analysis..."
grep -e "RagTag" $outputTMP/ragtag_output/ragtag.scaffold.agp | grep -e "W" > $outputTMP/TMP.1.txt
awk "NR>1" $outputTMP/ragtag_output/ragtag.scaffold.confidence.txt > $outputTMP/TMP.2.txt
paste $outputTMP/TMP.1.txt $outputTMP/TMP.2.txt > $outputTMP/$ACC.ragtag_scaffolds.$cutoff.txt

rm $outputTMP/TMP.*.txt

echo "Indexing RagTag REF..."
$SAMTOOLS faidx $outputTMP/$ACC.ragtag_scaffolds.$cutoff.fa

echo "Extracting only scaffolded chromosomes..."
$SAMTOOLS faidx $outputTMP/$ACC.ragtag_scaffolds.$cutoff.fa Chr1 Chr2 Chr3 Chr4 Chr5 > $outputTMP/$ACC.ragtag_scaffolds.Chr.fa
$SAMTOOLS faidx $outputTMP/$ACC.ragtag_scaffolds.Chr.fa

echo "Concatenating and indexing scaffolds plus SMALL contigs..."
cat $outputTMP/$ACC.ragtag_scaffolds.$cutoff.fa $outputTMP/$ACC.contigs.SMALL.$cutoff.fa > $outputTMP/$ACC.ragtag_scaffolds.fa
$SAMTOOLS faidx $outputTMP/$ACC.ragtag_scaffolds.fa

echo "Computing stats for assembly ..."
$ASSEMBLY/assembly-stats $outputTMP/$ACC.ragtag_scaffolds.Chr.fa > $outputTMP/$ACC.ragtag_scaffolds.Chr.stats.txt

conda deactivate


# End
date
echo "End script"
echo ""

