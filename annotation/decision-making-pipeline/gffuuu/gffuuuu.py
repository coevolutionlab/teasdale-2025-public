
from intervaltree import IntervalTree
from collections import defaultdict, Counter
from .gffparse import *
import json
from pprint import pprint
import argparse
import sys
import traceback


def handle_multigene(locus, ldat, overlap_threshold=3):
    n_genes = {ann: len(dat) for ann, dat in ldat.items()}
    anns = ["PASA", "Liftoff", "AUGUSTUS"]
    
    # Annoying conditionals
    ngc = [n_genes.get(a, 0) for a in anns]  # number of genes per annotator
    aae =  all(c == ngc[0] and c > 0 for c in ngc)  # all annotators equal and non_zero
    
    nzngc = {c for c in ngc if c > 0} # unique non-zero counts
    ozre = (sum(c == 0 for c in ngc) == 1 and len(nzngc) == 1)  # one is zero, rest are equal
    
    if aae or ozre: # see above
        # All equal number of genes. Split into ordered blocks and process independently.
        # this normally happens when UTRs overlap, but CDSs don't.
        res = []
        for i in range(max(ngc)):
            fakeldat = {ann: [ldat[ann][i], ] for ann in ["PASA", "AUGUSTUS", "Liftoff"] if ann in ldat}
            _, genes = handle_single(locus, fakeldat)
            res.extend(genes)
        return locus, res
    elif n_genes.get("Liftoff", 0) == 1 and n_genes.get("PASA", 0) == 1 and n_genes.get("AUGUSTUS", 0) > 1:
        # If one pasa and liftoff txs overlap, take pasa
        for pasatx in ldat["PASA"][0]["children"].values():
            for lotx in ldat["Liftoff"][0]["children"].values(): 
                if feature_distance(pasatx, lotx, "CDS") < overlap_threshold:
                    if "MERGED" in ldat["PASA"][0]["attributes"]["ID"]:
                        # Pasa recognises that the two augustuses are part of one tx, liftoff agrees, take pasa
                        ldat["PASA"][0]["attributes"]["confidence_reason"] = "pasa_merged_liftoff_agree_use_pasa"
                    else:
                        # Cases where PASA didn't technically merge it but they overlap anyway and the conclusion is the same
                        ldat["PASA"][0]["attributes"]["confidence_reason"] = "pasa_liftoff_agree_multigene_use_pasa"
                    return locus, [ldat["PASA"][0], ]
        # If pasa and liftoff disagree, trust Liftoff's homology over PolII. If liftoff is invalid, it's a pseudogene, and we handle this later
        ldat["Liftoff"][0]["attributes"]["confidence_reason"] = "pasa_merged_liftoff_disagree_use_liftoff"
        return locus, [ldat["Liftoff"][0], ]
    # As a global catch-all: take liftoff if it's there, else take pasa.
    for priority in ["Liftoff", "PASA", "AUGUSTUS"]:
        if priority in ldat:
            res = []
            for i in range(len(ldat[priority])):
                ldat[priority][i]["attributes"]["confidence_reason"] = f"catchall_multigene_take_{priority.lower()}"
                res.append(ldat[priority][i])
            return locus, res
    assert False, {locus: "; ".join(f"{k}={v}" for k, v in n_genes.items())} 

def handle_single(locus, ldat):
    # No isoseq cases:
    if not "PASA" in ldat:
        # don't have data from all tools, so can't all agree
        if "AUGUSTUS" in ldat and "Liftoff" in ldat:
            aug = ldat["AUGUSTUS"][0]
            liftoff = ldat["Liftoff"][0]
            for liftoff_tx in liftoff["children"].values():
                if features_equal(aug, liftoff_tx, "CDS"):
                    liftoff["attributes"]["confidence_reason"] = "aug_liftoff_cds_agree_use_liftoff"
                    return locus, [liftoff, ]
            # no txs are equal -> take liftoff
            liftoff["attributes"]["confidence_reason"] = "aug_liftoff_cds_disagree_use_liftoff"
            return locus, [liftoff,]
        if "AUGUSTUS" in ldat:
            aug = ldat["AUGUSTUS"][0]
            aug["attributes"]["confidence_reason"] = "only_aug"
            return locus, [aug, ]
        if "Liftoff" in ldat:
            liftoff = ldat["Liftoff"][0]
            liftoff["attributes"]["confidence_reason"] = "only_liftoff"
            return locus, [liftoff, ]
        assert False
    
    # Have isoseq
    pasa = ldat["PASA"][0]
    pasaid = pasa["attributes"]["ID"]
    
    aug = ldat["AUGUSTUS"][0]
    
    liftoff_agrees = False
    agrees = False
    for pasatx in pasa["children"].values():
        if "Liftoff" in ldat:
            # If present, and it agrees, add liftoff to the confidence reason (below)
            liftoff = ldat["Liftoff"][0]
            for liftoff_tx in liftoff["children"].values():
                if features_equal(pasatx, liftoff_tx, "CDS"):
                    liftoff_agrees = True
                    agrees = True
                    pasatx["attributes"]["matched_tx"] = "true"
                    pasa["attributes"]["confidence_reason"] = "pasa_liftoff_notaug_cds_agree_use_pasa"
            if not liftoff_agrees:
                # If we have liftoff, it must agree with Pasa for the happy cases below to happen, otherwise we handle this as a disagree outside this loop.
                continue
        # We often have additional transcripts in the pasa that don't equal the augustus. This make sure that if one tx is equal to augustus we count it as equal.
        if features_equal(pasatx, aug, "CDS"):
            agrees = True
            pasatx["attributes"]["matched_tx"] = "true"
            if liftoff_agrees:
                pasa["attributes"]["confidence_reason"] = "aug_liftoff_pasa_cds_agree_use_pasa"
            else:
                pasa["attributes"]["confidence_reason"] = "aug_pasa_cds_agree_use_pasa"
        if agrees:
            return locus, [pasa, ]
    if "Liftoff" in ldat:
        liftoff = ldat["Liftoff"][0]
        liftoff["attributes"]["confidence_reason"] = "liftoff_pasa_aug_disagree_use_liftoff"
        return locus, [liftoff, ]
    pasa["attributes"]["confidence_reason"] = "pasa_augustus_disagree_use_pasa"
    return locus, [pasa, ]


def handle_cases(locus, ldat):
    # Some special cases first
    for src in ["AUGUSTUS", "PASA", "Liftoff"]:
        if src in ldat and len(ldat[src]) != 1:
            # An annotator has more than one gene here
            return handle_multigene(locus, ldat)
        
    if all(x not in ldat for x in  ["AUGUSTUS", "PASA", "Liftoff"]):
        # only tama
        return locus, []
    
    return handle_single(locus, ldat)
    # Decided against this logic after all, as there is little reason for it except in only-aug cases, which we don't trust anyway
    #decision = res[0]["attributes"]["confidence_reason"]
    #if "AUGUSTUS" in ldat and "PASA" in ldat and decision not in {
    #                                           "aug_pasa_cds_agree_use_pasa",
    #                                           "aug_liftoff_pasa_cds_agree_use_pasa",
    #                                           "pasa_liftoff_cds_agree_use_pasa",
    #                                           "pasa_liftoff_notaug_cds_agree_use_pasa",
    #                                           "aug_liftoff_cds_agree_use_liftoff"}:
    #    aug = ldat["AUGUSTUS"][0]
    #    if sum([x[1] - x[0] for x in get_all_features(aug, "CDS")]) > 5000:
    #        # special case: augustus annotation is massive, so we use it as these are likely cases where the isoseq can't assay it.
    #        print(f"Override {decision} -> cds_too_long_for_isoseq", file=sys.stderr)
    #        
    #        aug["attributes"]["confidence_reason"] = "cds_too_long_for_isoseq_use_aug"
    #        return locus, [aug, ]
    #return locus, res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--loci",
                    help="BED locus file with cols chr, start0, stop, strand")
    #ap.add_argument("--sad", required=True,
    #                help="Sadness output gff")
    ap.add_argument("--decisions", required=True,
                    help="Output regions with decisions")
    ap.add_argument("--happy", required=True,
                    help="Processed output gff")
    ap.add_argument("gffs", nargs="+")
    args = ap.parse_args()
    
    loci = defaultdict(lambda: defaultdict(IntervalTree))
    loci_coords = {}
    i = 0
    print("loci at", args.loci)
    with open(args.loci) as fh: 
        for line in fh:
            i += 1
            id = f"gene{i:05d}"
            fields = line.rstrip().split("\t")
            chr, start, stop, strand = fields[:4]
            start = int(start) +1
            stop = int(stop)
            loci[chr][strand][start:stop] = id
            loci_coords[id] = (chr, start, stop, strand)
    print("N loci:", len(loci_coords))

    loci_data = defaultdict(list)
    for gff in args.gffs:
        gff_data = gff_heirarchy(gff)
        i = 0
        for gene, gene_data in gff_data.items():
            locus = loci[gene_data["seqid"]][gene_data["strand"]].overlap(gene_data["start"], gene_data["end"])
            if len(locus) > 0:
                i +=  1
                for loc in locus:
                    locus_id = loc.data
                    loci_data[locus_id].append(gene_data)
        print(f"Added {i} genes from {gff} ({len(gff_data) - i} missing)")
        
    res = {}
    j = 0
    print("Now scan over loci...")
    for locus, dat in loci_data.items():
        j += 1
        bysrc = dict()
        for d in dat:
            try:
                bysrc[d["source"]].append(d)
            except KeyError:
                bysrc[d["source"]] = [d,]
        try:
            locus, r = handle_cases(locus, bysrc)
            res[locus] = r
        except:
            #pprint(bysrc)
            raise

        
    print("Now write GFFs...")
    gene_decisions = {}
    genectr = 1
    with open(args.happy, "w") as fh,  open(args.decisions, "w") as decisionfh:
        print("##gff-version 3", file=fh)
        for i, (loc, locgenes) in enumerate(sorted(res.items())):
            for gene in locgenes:
                loc2 = f"gene{genectr:05d}"
                genectr += 1
                gene["attributes"]["dl20_automated_locus_id"] = loc
                gene_decisions[loc2] = gene["attributes"]["confidence_reason"]
                chr, start, end = gene["seqid"], gene["start"], gene["end"]
                write_gene(gene, file=fh)
                print(chr, start-1, end, loc2, 0, gene["strand"], f"{chr}:{start}-{end}", gene_decisions[loc2], loc, file=decisionfh, sep="\t")
    print("DONE! Stats follow\n")
    c = Counter(gene_decisions.values())
    for cls, cnt in  c.most_common():
        print(cls, cnt, sep="\t")

if __name__ == "__main__":
    main()
