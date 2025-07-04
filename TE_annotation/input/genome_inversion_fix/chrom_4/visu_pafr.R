
library(pafr, quietly=TRUE)



# Chrom 4 aligment 
paf_file_path <- "/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/input/genome_inversion_fix/chrom_4/chrom4_al.paf"
paf_aligment <- read_paf(paf_file_path)

dotplot(paf_aligment, order_by = 'qstart', label_seqs = TRUE)

plot_synteny(paf_aligment, q_chrom="at9879_1_chr4", t_chrom="Chr4", centre=TRUE)

