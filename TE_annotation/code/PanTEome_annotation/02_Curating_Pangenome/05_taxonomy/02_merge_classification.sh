#!/usr/bin/env bash

# Here we retrieve all the taxonomical classification we have done with TEsorter
# and andd them in the annotation file togfether with other supplementary files
# of the domains adquired.

cd TE_annotation/output/EDTA_curation/05_taxonomy/

# Retrieve the different classification:
#TE Order Superfamily Clade Complete  Strand  Domains
# Speciall case: Helitrons
# Because helitrons often adquire domains of other TEs,  then can often be
# missclasified. Thus, we will just retrieve those Helitrons that have been
# taxonomically classified as Helitrons. It will also act as another layer of
# verification ofr Helitron annotation.

tail -n +2 Helitrons/TE_family_classification_Helitron.fa.rexdb-plant.cls.tsv | sed '/Clade=unknown/d' |
sed 's/|Helitron//g' |
awk 'BEGIN{OFS=FS="\t"} {if($2 ~ /Helitron/) print "Name="$1"\tOrder="$2"\tClade="$4"\tTEsorterDB="$7}' >  TEsorter_Helitron_taxonomy.tsv
# TIR
tail -n +2 TIR/TE_family_classification_TIR.fa.rexdb-pnas.cls.tsv | sed '/Clade=unknown/d' |
awk 'BEGIN{OFS=FS="\t"} {print "Name="$1"\tOrder="$2"\tClade="$3"\tTEsorterDB="$7}' > TEsorter_TIR_taxonomy.tsv
# Lines
tail -n +2 Lines/pangenome_TElib_Lines.fa.rexdb-line.cls.tsv | sed '/Clade=unknown/d' |
awk 'BEGIN{OFS=FS="\t"} {print "Name="$1"\tOrder="$2"\tClade="$3"\tTEsorterDB="$7}' > TEsorter_Lines_taxonomy.tsv
# Sines
tail -n +2 Sines/TE_family_classification_Sines.fa.sine.cls.tsv | sed '/Clade=unknown/d' |
awk 'BEGIN{OFS=FS="\t"} {print "Name="$1"\tOrder="$2"\tClade="$3"\tTEsorterDB="$7}' > TEsorter_Sines_taxonomy.tsv
# LTR
tail -n +2 LTR/TE_family_classification_LTR.fa.rexdb-plant.cls.tsv | sed '/Clade=unknown/d' |
awk 'BEGIN{OFS=FS="\t"} {print "Name="$1"\tOrder="$3"\tClade="$4"\tTEsorterDB="$7}' > TEsorter_LTR_taxonomy.tsv

# Combine TEsorter tables:
cat TEsorter_Helitron_taxonomy.tsv  TEsorter_Lines_taxonomy.tsv  \
TEsorter_LTR_taxonomy.tsv  TEsorter_Sines_taxonomy.tsv  TEsorter_TIR_taxonomy.tsv > All_taxonomy.tsv
# Clanup
rm TEsorter_Helitron_taxonomy.tsv  TEsorter_Lines_taxonomy.tsv
rm TEsorter_LTR_taxonomy.tsv  TEsorter_Sines_taxonomy.tsv  TEsorter_TIR_taxonomy.tsv

# Because the Unassigned classification was so heterogeneous, we deal with it separately

# Format and clean the taxonomy table
cat All_taxonomy.tsv  |  sed 's/AT[1-5]TE[0-9]*_//'  |
cut -f1,2,3 | sort | uniq | grep -v "Clade=unknown" > All_taxonomy_clean.tsv

# Take majority vote for each TE family:
# Group first column by unique ID name and find the most abundant value from the third column
awk 'BEGIN{OFS=FS="\t"} NR>1{count[$1"|"$3]++} END{for (key in count) print key, $2, count[key]}' All_taxonomy_clean.tsv |
sort -k1,1 -k4,4nr |
awk 'BEGIN{OFS="\t"} {split($1, parts, "|"); id=parts[1]; value=parts[2];
  if (!max[id]) {max[id]=value; max_count[id]=$4}
  else {if ($4 > max_count[id]) {max_count[id]=$4; max[id]=value}}}
  END{for (id in max) print id, max[id]}' > All_taxonomy_final.tsv

#Cleanup
rm All_taxonomy.tsv All_taxonomy_clean.tsv

echo "Done"
