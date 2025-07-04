## Helitron Curation

This folder contains the scripts used to curate Helitrons annotated in a signature base fashion by EDTA.
We are not going to remove any helitron, we are going to increase the layers of confidence in the annotation in 2 ways:

    1.- Examine whether a TE family has at least one intact member. (TEfam_intacts=[integer])
    2.- Examine whether a TE family has a Hel domain in any of its members. (RXDB_Hel_domain_fam=YES/NO)
    3.- Independently run EAhelitron tool and intersect both annotations.(EAHelitron=YES/NO)
    4.- Add to the final annotation any helitron annotated by EAhelitron that does not overlap with any other TE.
