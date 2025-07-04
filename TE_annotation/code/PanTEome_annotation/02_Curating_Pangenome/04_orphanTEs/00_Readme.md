## Orphan TEs

In our TE annotation there are several TEs that are not included in any
TE family because they are structurally intact, but single copy. This is
probably due to running the raw EDTA module independently for each genome. To
correct this, we are going to cluster them into families, following the
80/80/80 rule.

First we are going to try to incorporate them in any known family using blast.
Then, we will try to cluster the rest of copies with no correspondence with a
known TE family. Cluster with 2 or more copies will then  be assigned new family
names and  TE models incorporated to the TE library of the pangenome. 
