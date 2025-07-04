#!/bin/bash

###separate BUSCO summary categories

for i in $(ls at*.full_table.tsv); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/' | awk '$2 == "Missing" {print $1}' > $NAME.missingBUSCOs.list
	cat $i | awk '$1 !~/^#/' | awk '$2 == "Fragmented" {print $1}' > $NAME.fragmentedBUSCOs.list
	cat $i | awk '$1 !~/^#/' | awk '$2 == "Duplicated" {print $1}' > $NAME.duplicatedBUSCOs.list
done



###get venn matrix for missing BUSCOs

cat at*missingBUSCOs.list | sort | uniq > missingBUSCOs.list.tmp
echo "buscoID" > missingBUSCOs
cat at*missingBUSCOs.list | sort | uniq >> missingBUSCOs

for i in $(ls at*.missingBUSCOs.list); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
#	NAME2=$(echo $i | awk -F'_' '{print $1}')
	DATA=`cat missingBUSCOs.list.tmp`
	echo $NAME > $NAME.missingBUSCOs.matrix.tmp
	for line in $DATA; do
		if
		  grep -q $line $i; then
			echo "1" >> $NAME.missingBUSCOs.matrix.tmp
		else
		 	echo "0" >> $NAME.missingBUSCOs.matrix.tmp
		fi
	done
done



###get venn matrix for fragmented BUSCOs

cat at*.fragmentedBUSCOs.list | sort | uniq > fragmentedBUSCOs.list.tmp
echo "buscoID" > fragmentedBUSCOs
cat at*fragmentedBUSCOs.list | sort | uniq >> fragmentedBUSCOs

for i in $(ls at*fragmentedBUSCOs.list); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
#       NAME2=$(echo $i | awk -F'_' '{print $1}')
        DATA=`cat fragmentedBUSCOs.list.tmp`
        echo $NAME > $NAME.fragmentedBUSCOs.matrix.tmp
        for line in $DATA; do
                if
                  grep -q $line $i; then
                        echo "1" >> $NAME.fragmentedBUSCOs.matrix.tmp
                else
                        echo "0" >> $NAME.fragmentedBUSCOs.matrix.tmp
                fi
        done
done



###get venn matrix for duplicated BUSCOs

cat at*.duplicatedBUSCOs.list | sort | uniq > duplicatedBUSCOs.list.tmp
echo "buscoID" > duplicatedBUSCOs
cat at*.duplicatedBUSCOs.list | sort | uniq >> duplicatedBUSCOs

for i in $(ls at*duplicatedBUSCOs.list); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
#       NAME2=$(echo $i | awk -F'_' '{print $1}')
        DATA=`cat duplicatedBUSCOs.list.tmp`
        echo $NAME > $NAME.duplicatedBUSCOs.matrix.tmp
        for line in $DATA; do
                if
                  grep -q $line $i; then
                        echo "1" >> $NAME.duplicatedBUSCOs.matrix.tmp
                else
                        echo "0" >> $NAME.duplicatedBUSCOs.matrix.tmp
                fi
        done
done



paste missingBUSCOs at*.missingBUSCOs.matrix.tmp | sed 's/\t/;/g' > missingBUSCOsIntersection.4R
paste fragmentedBUSCOs at*.fragmentedBUSCOs.matrix.tmp | sed 's/\t/;/g' > fragmentedBUSCOsIntersection.4R
paste duplicatedBUSCOs at*.duplicatedBUSCOs.matrix.tmp | sed 's/\t/;/g' > duplicatedBUSCOsIntersection.4R

rm missingBUSCOs.list.tmp fragmentedBUSCOs.list.tmp duplicatedBUSCOs.list.tmp
rm missingBUSCOs fragmentedBUSCOs duplicatedBUSCOs
rm at*missingBUSCOs.matrix.tmp at*fragmentedBUSCOs.matrix.tmp at*duplicatedBUSCOs.matrix.tmp
rm at*missingBUSCOs.list at*fragmentedBUSCOs.list at*duplicatedBUSCOs.list
