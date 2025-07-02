for x in output/*nlr_annotator.gff3
do 
    bash scripts/gfffix <$x >${x%%.gff3}.acutal.gff3
done
