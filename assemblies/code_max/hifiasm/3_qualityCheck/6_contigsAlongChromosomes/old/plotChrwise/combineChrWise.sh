#!/bin/bash

for i in $(ls at*.chrLength); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	grep "Chr1" $i | sed -e 's/\_RagTag\_RagTag//g' | awk -v pat=$NAME '{print pat, $2}' > $NAME.chr1Length.tmp
	grep "Chr2" $i | sed -e 's/\_RagTag\_RagTag//g' | awk -v pat=$NAME '{print pat, $2}' > $NAME.chr2Length.tmp
	grep "Chr3" $i | sed -e 's/\_RagTag\_RagTag//g' | awk -v pat=$NAME '{print pat, $2}' > $NAME.chr3Length.tmp
	grep "Chr4" $i | sed -e 's/\_RagTag\_RagTag//g' | awk -v pat=$NAME '{print pat, $2}' > $NAME.chr4Length.tmp
	grep "Chr5" $i | sed -e 's/\_RagTag\_RagTag//g' | awk -v pat=$NAME '{print pat, $2}' > $NAME.chr5Length.tmp

	grep "Chr1" $NAME.contigs1 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr1.contigs1.tmp
	grep "Chr1" $NAME.contigs2 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr1.contigs2.tmp

	grep "Chr2" $NAME.contigs1 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr2.contigs1.tmp
        grep "Chr2" $NAME.contigs2 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr2.contigs2.tmp

	grep "Chr3" $NAME.contigs1 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr3.contigs1.tmp
        grep "Chr3" $NAME.contigs2 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr3.contigs2.tmp

	grep "Chr4" $NAME.contigs1 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr4.contigs1.tmp
        grep "Chr4" $NAME.contigs2 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr4.contigs2.tmp

	grep "Chr5" $NAME.contigs1 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr5.contigs1.tmp
        grep "Chr5" $NAME.contigs2 | awk -F':' -v pat=$NAME '{print pat":"$2}' > $NAME.chr5.contigs2.tmp

echo $NAME
done

echo test > allChr1.scaffolds.fig
echo test > allChr2.scaffolds.fig
echo test > allChr3.scaffolds.fig
echo test > allChr4.scaffolds.fig
echo test > allChr5.scaffolds.fig

mkdir allChr1_out
mkdir allChr2_out
mkdir allChr3_out
mkdir allChr4_out
mkdir allChr5_out

cat at*chr1Length.tmp > allChr1_out/allChr1.chrLength
cat at*chr2Length.tmp > allChr2_out/allChr2.chrLength
cat at*chr3Length.tmp > allChr3_out/allChr3.chrLength
cat at*chr4Length.tmp > allChr4_out/allChr4.chrLength
cat at*chr5Length.tmp > allChr5_out/allChr5.chrLength

cat at*chr1.contigs1.tmp > allChr1_out/allChr1.contigs1
cat at*chr1.contigs2.tmp > allChr1_out/allChr1.contigs2

cat at*chr2.contigs1.tmp > allChr2_out/allChr2.contigs1
cat at*chr2.contigs2.tmp > allChr2_out/allChr2.contigs2

cat at*chr3.contigs1.tmp > allChr3_out/allChr3.contigs1
cat at*chr3.contigs2.tmp > allChr3_out/allChr3.contigs2

cat at*chr4.contigs1.tmp > allChr4_out/allChr4.contigs1
cat at*chr4.contigs2.tmp > allChr4_out/allChr4.contigs2

cat at*chr5.contigs1.tmp > allChr5_out/allChr5.contigs1
cat at*chr5.contigs2.tmp > allChr5_out/allChr5.contigs2



rm at*chr*.contigs1.tmp
rm at*chr*.contigs2.tmp
rm at*chr*Length.tmp
