#!/usr/bin/env bash

# While running the TE annotation, we fix an scaffolding error in the at9879 assembly. 
# Now, we need to firt, replace the old assembly of at9879 with the new one in the 
# pangenome fasta file. Second, we have to correct the annotation for at9879 as well, 
# For this, we liftover the old annotation to the new assembly, ie, we change 
#coordinates of the annotated elements. 

# First, create the folder:
mkdir -p TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/
cd TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/


######## MAKE A NEW PANGENOME ############

mkdir -p ./01_new_pangenome/
cd ./01_new_pangenome/

# Remove the at9879 assembly from the pangenome:
old_pangenome_fasta="TE_annotation/output/PANGENOME_EDTA/pangenome.fasta"
seqkit grep -w 0 -v -nrp "at9879"  $old_pangenome_fasta > no_at9879_panG.fa

# Change the names of the fasta headers fro the new pansm terminology:
declare -A chrom_name_dict=(
["at6137_1"]="at6137_1_chr1"
["at6137_2"]="at6137_1_chr2"
["at6137_3"]="at6137_1_chr3"
["at6137_4"]="at6137_1_chr4"
["at6137_5"]="at6137_1_chr5"
["at6137_ptg81l"]="at6137_9_u81"
["at6923_1"]="at6923_1_chr1"
["at6923_2"]="at6923_1_chr2"
["at6923_3"]="at6923_1_chr3"
["at6923_4"]="at6923_1_chr4"
["at6923_5"]="at6923_1_chr5"
["at6923_ptg94l"]="at6923_9_u94"
["at6923_ptg29l"]="at6923_9_u29"
["at6929_1"]="at6929_1_chr1"
["at6929_2"]="at6929_1_chr2"
["at6929_3"]="at6929_1_chr3"
["at6929_4"]="at6929_1_chr4"
["at6929_5"]="at6929_1_chr5"
["at6929_ptg454l"]="at6929_9_u454"
["at6929_ptg732l"]="at6929_9_u732"
["at6929_ptg745l"]="at6929_9_u745"
["at6929_ptg979l"]="at6929_9_u979"
["at6929_ptg37l"]="at6929_9_u1037"
["at6929_ptg1687l"]="at6929_9_u1687"
["at7143_1"]="at7143_1_chr1"
["at7143_2"]="at7143_1_chr2"
["at7143_3"]="at7143_1_chr3"
["at7143_4"]="at7143_1_chr4"
["at7143_5"]="at7143_1_chr5"
["at7143_ptg29l"]="at7143_9_u29"
["at7143_ptg284l"]="at7143_9_u284"
["at8285_1"]="at8285_1_chr1"
["at8285_2"]="at8285_1_chr2"
["at8285_3"]="at8285_1_chr3"
["at8285_4"]="at8285_1_chr4"
["at8285_5"]="at8285_1_chr5"
["at9104_1"]="at9104_1_chr1"
["at9104_2"]="at9104_1_chr2"
["at9104_3"]="at9104_1_chr3"
["at9104_4"]="at9104_1_chr4"
["at9104_5"]="at9104_1_chr5"
["at9104_ptg52l"]="at9104_9_u52"
["at9336_1"]="at9336_1_chr1"
["at9336_2"]="at9336_1_chr2"
["at9336_3"]="at9336_1_chr3"
["at9336_4"]="at9336_1_chr4"
["at9336_5"]="at9336_1_chr5"
["at9336_ptg62l"]="at9336_9_u62"
["at9336_ptg166l"]="at9336_9_u166"
["at9336_ptg244l"]="at9336_9_u244"
["at9336_ptg45l"]="at9336_9_u45"
["at9336_ptg63l"]="at9336_9_u63"
["at9336_ptg97l"]="at9336_9_u97"
["at9336_ptg114l"]="at9336_9_u114"
["at9336_ptg116l"]="at9336_9_u116"
["at9336_ptg143l"]="at9336_9_u143"
["at9336_ptg153l"]="at9336_9_u153"
["at9336_ptg2l"]="at9336_9_u202"
["at9336_ptg258l"]="at9336_9_u258"
["at9336_ptgl"]="at9336_9_u420"
["at9336_ptg476l"]="at9336_9_u476"
["at9503_1"]="at9503_1_chr1"
["at9503_2"]="at9503_1_chr2"
["at9503_3"]="at9503_1_chr3"
["at9503_4"]="at9503_1_chr4"
["at9503_5"]="at9503_1_chr5"
["at9503_ptgl"]="at9503_9_u50"
["at9503_ptg136l"]="at9503_9_u136"
["at9578_1"]="at9578_1_chr1"
["at9578_2"]="at9578_1_chr2"
["at9578_3"]="at9578_1_chr3"
["at9578_4"]="at9578_1_chr4"
["at9578_5"]="at9578_1_chr5"
["at9578_ptg75l"]="at9578_9_u75"
["at9744_1"]="at9744_1_chr1"
["at9744_2"]="at9744_1_chr2"
["at9744_3"]="at9744_1_chr3"
["at9744_4"]="at9744_1_chr4"
["at9744_5"]="at9744_1_chr5"
["at9744_ptg24l"]="at9744_9_u24"
["at9762_1"]="at9762_1_chr1"
["at9762_2"]="at9762_1_chr2"
["at9762_3"]="at9762_1_chr3"
["at9762_4"]="at9762_1_chr4"
["at9762_5"]="at9762_1_chr5"
["at9762_ptg64l"]="at9762_9_u64"
["at9762_ptg42l"]="at9762_9_u42"
["at9762_ptg135l"]="at9762_9_u135"
["at9806_1"]="at9806_1_chr1"
["at9806_2"]="at9806_1_chr2"
["at9806_3"]="at9806_1_chr3"
["at9806_4"]="at9806_1_chr4"
["at9806_5"]="at9806_1_chr5"
["at9806_ptg28l"]="at9806_9_u28"
["at9806_ptgl"]="at9806_9_u30"
["at9830_1"]="at9830_1_chr1"
["at9830_2"]="at9830_1_chr2"
["at9830_3"]="at9830_1_chr3"
["at9830_4"]="at9830_1_chr4"
["at9830_5"]="at9830_1_chr5"
["at9830_ptg393l"]="at9830_9_u393"
["at9830_ptgl"]="at9830_9_u470"
["at9830_ptg1136l"]="at9830_9_u1136"
["at9847_1"]="at9847_1_chr1"
["at9847_2"]="at9847_1_chr2"
["at9847_3"]="at9847_1_chr3"
["at9847_4"]="at9847_1_chr4"
["at9847_5"]="at9847_1_chr5"
["at9847_ptg875l"]="at9847_9_u875"
["at9852_1"]="at9852_1_chr1"
["at9852_2"]="at9852_1_chr2"
["at9852_3"]="at9852_1_chr3"
["at9852_4"]="at9852_1_chr4"
["at9852_5"]="at9852_1_chr5"
["at9879_1"]="at9879_1_chr1"
["at9879_2"]="at9879_1_chr2"
["at9879_3"]="at9879_1_chr3"
["at9879_4"]="at9879_1_chr4"
["at9879_5"]="at9879_1_chr5"
["at9883_1"]="at9883_1_chr1"
["at9883_2"]="at9883_1_chr2"
["at9883_3"]="at9883_1_chr3"
["at9883_4"]="at9883_1_chr4"
["at9883_5"]="at9883_1_chr5"
["at9883_ptg26l"]="at9883_9_u26"
["at9883_ptg121l"]="at9883_9_u121"
["at9900_1"]="at9900_1_chr1"
["at9900_2"]="at9900_1_chr2"
["at9900_3"]="at9900_1_chr3"
["at9900_4"]="at9900_1_chr4"
["at9900_5"]="at9900_1_chr5"
["at9900_ptg26l"]="at9900_9_u26"
["at9900_ptg177l"]="at9900_9_u177"
["at9900_ptg178l"]="at9900_9_u178"
["at9900_ptg763l"]="at9900_9_u763"
)

# Rename old genome with new names:
while IFS= read -r line; do
  # Iterate over each key in the chrom_name dict.
  if [[ $line == ">"* ]]; then
      for key in "${!chrom_name_dict[@]}"; do
  # Replace the old name (key) with the new name (value):
      value="${chrom_name_dict[$key]}"
      line=${line//$key/$value}
      done
  fi
  # Append the modified line to the new genome:
  echo "$line"
done < no_at9879_panG.fa > no_at9879_panG_renamed.fa

# Add the new at9879 assembly:
new_at9879="TE_annotation/input/genome_inversion_fix/at9879.fasta"
cat no_at9879_panG_renamed.fa ${new_at9879} > ../new_pangenome.fasta
cd ../
samtools faidx new_pangenome.fasta
echo "Done renaming the pangenome"

############ LIFTOFF OF at9879 ##################################
# We corrected one of the chromsomes of at9879 that
# presented an inversion. Thus,  we also need to correct
# the annotation for this accession. For that we use
# transanno:
# https://github.com/informationsea/transanno
# and CrossMap (v0.5.2) 
# https://crossmap.readthedocs.io/en/latest/
# We install CrossMap with conda.

mkdir -p 02_liftover_TEs/
cd 02_liftover_TEs/
# Retrieve the correct genome:
ln -s TE_annotation/input/genome_inversion_fix/at9879.fasta ./at9879_corrected.fasta 
# Retrieve the old genome:
ln -s TE_annotation/input/genomes/at9879.fasta ./at9879_old.fasta

# Retrieve the annotation
TE_intacts="TE_annotation/output/EDTA_curation/06_QoL/01_rename_chrom/pangenome_QoL_01_TEintacts.gff3"
TE_all="TE_annotation/output/EDTA_curation/06_QoL/01_rename_chrom/pangenome_QoL_01_TEfull.gff3"
pangenome_corrected="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/new_pangenome.fasta"
pangenome_corrected_fai="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/new_pangenome.fasta.fai"
# retrieve the TEs of at9879 and modify those strand info with "?" instead of ".".
grep "^at9879" ${TE_intacts} |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' > at9879_intacts.gff3
grep "^at9879" ${TE_all} |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' > at9879_full.gff3

# Obtain transanno to create the CHAIN file:
# Get the tool:
# wget -P /ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/  https://github.com/informationsea/transanno/releases/download/v0.3.0/transanno-x86_64-unknown-linux-musl-v0.3.0.zip
# unzip  /ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/transanno-x86_64-unknown-linux-musl-v0.3.0.zip -d  /ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/
# Make var with tool:
transanno="TE_annotation/code/transanno-x86_64-unknown-linux-musl-v0.3.0/transanno"
# Use minimap  version2.24-r1122
minimap2 -cx asm5 --cs at9879_corrected.fasta at9879_old.fasta > PAF_FILE.paf
$transanno minimap2chain PAF_FILE.paf --output CHAINFILE.chain
# with the CHAIN file, we use CrossMap (v0.5.2) to perform the liftover:

CrossMap.py gff  CHAINFILE.chain at9879_intacts.gff3 at9879_intacts.lifted.gff3
CrossMap.py gff  CHAINFILE.chain at9879_full.gff3 at9879_full.lifted.gff3

# After lifting all TEs from at 9879, We bring the rest of TEs of the anno,
# and modify those strand info with "?" instead of ".".
grep -v "^at9879" ${TE_intacts} |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' |
cat - at9879_intacts.lifted.gff3 |
bedtools sort -faidx ${pangenome_corrected_fai} -i - > ../all_anno_lifted_intacts.gff3


grep -v "^at9879"  ${TE_all} |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' |
cat - at9879_full.lifted.gff3 |
bedtools sort -faidx  ${pangenome_corrected_fai} -i - >  ../all_anno_lifted_full.gff3




###### Correct also the satrell;ite repeat annotation:

mkdir -p 03_liftover_Sat/ 
cd 03_liftover_Sat/

# Import the Satellite repeat anotation from 01_tandem_repeats:
cp /ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/EDTA_curation/01_Tandem_repeats/pangenome_sat_repeats_TRF_TRASH.gff3 .
# Change  the  chromosome names of this annotation:

# Iterate over each line in the GFF TE full annotation
while IFS= read -r line; do
# Iterate over each key in the dictionary
  for key in "${!chrom_name_dict[@]}"; do
# Replace the old name (key) with the new name (value)
    line=${line//$key/${chrom_name_dict[$key]}}
  done
# Append the modified line to a new file.
  echo "$line" >> pangenome_sat_repeats_TRF_TRASH_renamed.gff3
done < pangenome_sat_repeats_TRF_TRASH.gff3

# Extract at9879
grep "^at9879"  pangenome_sat_repeats_TRF_TRASH_renamed.gff3  |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' > at9879_sat_repeats_TRF_TRASH_renamed.gff3
# lift it over using the same CHAINFILE as before:
CrossMap.py gff ../02_liftover_TEs/CHAINFILE.chain at9879_sat_repeats_TRF_TRASH_renamed.gff3 at9879_sat_repeats_TRF_TRASH_renamed_lifted.gff3

# Merge it with the rest of the annotation:

grep -v "^at9879"  pangenome_sat_repeats_TRF_TRASH_renamed.gff3 |
awk -v OFS='\t' '{gsub(/\?/, ".", $7); print}' |
cat - at9879_sat_repeats_TRF_TRASH_renamed_lifted.gff3 |
bedtools sort -faidx  ${pangenome_corrected_fai} -i - >  ../pangenome_sat_repeats_TRF_TRASH_renamed_lifted.gff3

echo "DONE!"
