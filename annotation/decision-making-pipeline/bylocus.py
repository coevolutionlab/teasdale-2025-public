# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

from intervaltree import IntervalTree
from collections import defaultdict
from gffuuu.gffparse import gff_heirarchy, gffInfoFields
import json
from pprint import pprint

loci = defaultdict(lambda: defaultdict(IntervalTree))
loci_coords = {}
i = 0
#with open("input/at6923_loci.bed") as fh: 
with open("input/at6923_nlrloci.bed") as fh: 
#with open("at9900_loci_NLRs.bed") as fh:
    for line in fh:
        i += 1
        id = f"gene{i:05d}"
        fields = line.rstrip().split("\t")
        chr, start, stop, strand = fields[:4]
        start = int(start) +1
        stop = int(stop)
        loci[chr][strand][start:stop] = id
        loci_coords[id] = f"{chr}:{start}-{stop}"

annots = {"augustus": "input/at6923.augustus.gff",
          "liftoff": 'input/at6923.liftoff.protonly.gff',
          "pasa": "input/at6923.pasa.fix.gff",
          "tama": "input/at6923.tama-v2.fix.gff"}

# + tags=[]
loci_data = defaultdict(list)
for annot, gff in annots.items():
    gff_data = gff_heirarchy(gff)
    for gene, gene_data in gff_data.items():
        locus = loci[gene_data["seqid"]][gene_data["strand"]].overlap(gene_data["start"], gene_data["end"])
        if len(locus) > 0:
            locus_id = list(locus)[0].data
            loci_data[locus_id].append(gene_data)


# -

def get_all_features(annot, ftype):
    feat = set()
    if annot["type"] == ftype:
        feat.add((annot["start"], annot["end"], annot["strand"], annot["type"]))
    for child in annot.get("children", {}).values():
        feat.update(get_all_features(child, ftype))
    return feat


# +
def features_equal(a, b, ftype):
    a = set(get_all_features(a, ftype))
    b = set(get_all_features(b, ftype))
    return a == b

def feature_distance(a, b, ftype):
    def overlap(a, b):
        return a[0] <= b[0] <= a[1] or a[0] <= b[1] <= a[1]
    a = list(get_all_features(a, ftype))
    b = list(get_all_features(b, ftype))
    ovl = list()
    noovl = list()
    b_with_ovl = set()
    for ai in range(len(a)):
        for bi in range(len(b)):
            if overlap(a[ai], b[bi]):
                ovl.append((a[ai], b[bi]))
                b_with_ovl.add(b[bi])
                break
        else:
            # a does not overlap with an b
            noovl.append(a[ai])
    for bi in range(len(b)):
        if b[bi] not in b_with_ovl:
            noovl.append(b[bi])
    dist = 0
    for A, B in ovl:
        dist += abs(A[1] - B[1]) + abs(A[0] - B[0])
    for x in noovl:
        dist += x[1] - x[0]
    return dist


# -

#pprint(loci_data["gene00003"])
features_equal(loci_data["gene00001"][0], loci_data["gene00001"][1], "CDS")
feature_distance(loci_data["gene00001"][0], loci_data["gene00001"][1], "CDS")


def handle_nopasa(locus, ldat):
    if "AUGUSTUS" in ldat and "Liftoff" in ldat:
        aug = ldat["AUGUSTUS"][0]
        liftoff = ldat["Liftoff"][0]
        for liftoff_tx in liftoff["children"].values():
            if features_equal(aug, liftoff_tx, "CDS"):
                liftoff["attributes"]["confidence_reason"] = "aug_liftoff_cds_agree_use_liftoff"
                return {locus: liftoff}
        # no txs are equal???
        aug["attributes"]["confidence_reason"] = "aug_liftoff_cds_disagree_use_aug"
        return {locus: aug}
    if "AUGUSTUS" in ldat:
        aug = ldat["AUGUSTUS"][0]
        aug["attributes"]["confidence_reason"] = "only_aug"
        return {locus: aug}
    if "Liftoff" in ldat:
        liftoff = ldat["Liftoff"][0]
        liftoff["attributes"]["confidence_reason"] = "only_liftoff"
        return {locus: liftoff}
    assert False


def handle_multigene(locus, ldat):
    n_genes = {ann: len(dat) for ann, dat in ldat.items()}
    print(n_genes)
    if n_genes.get("only_liftoffLiftoff", 0) == 1 and n_genes.get("PASA", 0) == 1 and n_genes.get("AUGUSTUS", 0) > 1 and "MERGED" in ldata["PASA"][0]["attributes"]["ID"]:
        print("handling pasa merged gene")
        for pasatx in ldat["PASA"][0]["children"].values():
            for lotx in ldat["Liftoff"][0]["children"].values(): 
                if feature_distance(pasatx, lotx, "CDS") < 18:
                    ldat["PASA"][0]["attributes"]["confidence_reason"] = "pasa_merged_liftoff_agree_use_pasa"
                    return {locus: ldat["PASA"][0]}
    if n_genes.get("Liftoff", 0) ==  n_genes.get("AUGUSTUS", 0) and n_genes.get("AUGUSTUS", 0) > 0:
        print("handling nLO == nAUG")
        ret = {}    
        for i in range(n_genes["Liftoff"]):
            sublocus = f"{locus}-sub{i+1}"
            ret[sublocus] = "liftoff_augustus_disagree_subgene_isoseq_merges_toohard"
            aug = ldat["AUGUSTUS"][i]
            lo =  ldat["Liftoff"][i]
            for lotx in ldat["Liftoff"][i]["children"].values(): 
                if feature_distance(aug, lotx, "CDS") < 18:
                    lo["attributes"]["confidence_reason"] = "liftoff_augustus_agree_subgene_isoseq_merges_use_liftoff"
                    ret[sublocus] = lo
            if n_genes.get("PASA", 0) == n_genes["Liftoff"]:
                pasa = ldat["PASA"][i]
                for lotx in lo["children"].values(): 
                    for pasatx in pasa["children"].values():
                        if feature_distance(pasatx, lotx, "CDS") < 18 and feature_distance(aug, lotx, "CDS") < 18:
                            pasa["attributes"]["confidence_reason"] = "aug_liftoff_pasa_agree_subgene_tama_merges_use_pasa"
                            ret[sublocus] = pasa
        return ret
    return {locus: "; ".join(f"{k}={v}" for k, v in n_genes.items())} 


def handle_cases(locus, ldat):
    many_liftoffs = False
    for src in ["AUGUSTUS", "PASA", "Liftoff"]:
        if src in ldat and len(ldat[src]) != 1:
            # An annotator has more than one gene here
            return handle_multigene(locus, ldat)
        
    if all(x not in ldat for x in  ["AUGUSTUS", "PASA", "Liftoff"]):
        # only tama
        return {locus: "only_tama"}
    
    if not "PASA" in ldat:
        # don't have data from all tools, so can't all agree
        #print("Not all annots present")
        return handle_nopasa(locus, ldat)
    
    pasa = ldat["PASA"][0]
    pasaid = pasa["attributes"]["ID"]
    
    if "AUGUSTUS" not in ldat:
        print(ldat)
        return {locus: "NO AUG"}
    
    aug = ldat["AUGUSTUS"][0]
    pasa["attributes"]["confidence_reason"] = "pasa_cds_different_use_pasa"
    liftoff_agrees = False
    for pasatx in pasa["children"].values():
        if not many_liftoffs and "Liftoff" in ldat:
            # If present, and it agrees, add liftoff to the confidence reason (below)
            liftoff = ldat["Liftoff"][0]
            for liftoff_tx in liftoff["children"].values():
                if features_equal(pasatx, liftoff_tx, "CDS"):
                    liftoff_agrees = True
                    pasa["attributes"]["confidence_reason"] = "pasa_liftoff_cds_agree_use_pasa"
        # We often have additional transcripts in the pasa that don't equal the augustus. This make sure that if one tx is equal to augustus we count it as equal.
        if features_equal(pasatx, aug, "CDS"):
            if liftoff_agrees:
                pasa["attributes"]["confidence_reason"] = "aug_liftoff_pasa_cds_agree_use_pasa"
            else:
                pasa["attributes"]["confidence_reason"] = "aug_pasa_cds_agree_use_pasa"
            return {locus: pasa}
    if sum([x[1] - x[0] for x in get_all_features(aug, "CDS")]) > 5000:
        # special case: augustus annotation is massive, so we use it as these are likely cases where the isoseq can't assay it.
        aug["attributes"]["confidence_reason"] = "aug_pasa_cds_disagree_but_cds_too_long_for_isoseq_use_aug"
        return {locus: aug}
    return {locus: pasa}


# + tags=[]
res = {}
j = 0
for locus, dat in loci_data.items():
    j += 1
    bysrc = dict()
    for d in dat:
        try:
            bysrc[d["source"]].append(d)
        except KeyError:
            bysrc[d["source"]] = [d,]
    try:
        r = handle_cases(locus, bysrc)
    except:
        pprint(bysrc)
        raise
        
    if r:
        res.update(r)
# -

len(res)


def attr2line(attrs):
    from urllib.parse import quote as Q
    return ";".join("=".join((Q(k), Q(v))) for k, v in attrs.items())


def prefix_name(entry, sid):
    name = entry["attributes"].get("Name")
    if name:
        name = f"{sid}_{name}"
    else:
        name = sid
    entry["attributes"]["Name"] = name
def write_gene(gene, geneid=None, file=None, changenames=True):
    def write_line(entry):
        x = [entry[field] for i, field in enumerate(gffInfoFields)]
        x[-1] = attr2line(x[-1])
        print(*x, sep="\t", file=file)
    if not geneid:
        geneid = gene["attributes"]["ID"]
    gene["attributes"]["ID"] = geneid
    prefix_name(gene, geneid)
    write_line(gene)
    subids = Counter()
    for child in gene.get("children", {}).values():
        ct = child["type"]
        subids[ct] += 1
        ci = subids[ct]
        subid = f"{geneid}_{ct}{ci:02d}"
        child["attributes"]["ID"] = subid
        child["attributes"]["Parent"] = geneid
        prefix_name(child, subid)
        write_line(child)
        gcids = Counter()
        for gchild in child.get("children", {}).values():
            gt = gchild["type"]
            gcids[gt] += 1
            gi = gcids[gt]
            gcid = f"{subid}_{gt}{gi:02d}"
            gchild["attributes"]["ID"] = gcid
            gchild["attributes"]["Parent"] = subid
            prefix_name(gchild, gcid)
            write_line(gchild)       
    print("###", file=file)


# + tags=[]
with open("at6923_processed.gff3", "w") as fh, \
     open("at6923_sadness.gff3", "w") as sadfh:
    print("##gff-version 3", file=fh)
    print("##gff-version 3", file=sadfh)
    for loc, gene in res.items():
        if isinstance(gene, dict):
            write_gene(gene, f"at6923_{loc}", file=fh)
        else:
            for gene in loci_data[loc]:
                src = gene["source"]
                write_gene(gene, file=sadfh)
# -

from collections import Counter
c = Counter()
for loc, x in res.items():
    if isinstance(x, dict):
        c[x["attributes"]["confidence_reason"]] += 1
    else:
        if '-sub' in loc:
            loc = loc[:-5]
        print(loc, loci_coords[loc])
        c["toohard"] += 1
c.most_common()

sum(c.values())

7840 + 821

[('aug_liftoff_pasa_cds_agree_use_pasa', 42),
 ('some annots n genes != 1', 36),
 ('aug_liftoff_cds_disagree_use_aug', 33),
 ('aug_liftoff_cds_agree_use_liftoff', 26),
 ('aug_pasa_cds_agree_use_pasa', 21),
 ('only_aug', 17),
 ('pasa_liftoff_cds_agree_use_pasa', 11),
 ('pasa_cds_different_use_pasa', 10),
 ('aug_pasa_cds_disagree_but_cds_too_long_for_isoseq_use_aug', 1)]

sad = {l: loci_data[l] for l, v in res.items() if v == 'some annots n genes != 1'}

for loc, ldat in sad.items():
    for l in ldat:
        S, s, e = l["seqid"], l["start"], l["end"]
        print(, l["strand"], l["source"], sep="\t")


