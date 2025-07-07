for acc in at6923 at6929 at7143 at8285 at9104 at9336 at9503 at9578 at9744 at9762 at9806 at9830 at9847 at9852 at9879 at9883 at9900
do
    mkdir -p igv/${acc}
    blsl genigvjs \
        --reference ../../assembly-and-annotation/output/01_assembly/03_inversion_fixed/${acc}.fasta \
        --outdir igv/${acc}  \
        ${acc}_hodgepodge.gff3
        
done
