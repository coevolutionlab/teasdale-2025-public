#!/usr/bin/env python
# coding: utf-8

# ABANDON HOPE, ALL WHO ENTER HERE

# In[1]:


from datetime import datetime
EXPORT_VERSION = f"{datetime.now().strftime('%Y%m%d-%H%M%S')}_v3"
EXPORT_VERSION


# In[2]:


from gffuuu import gffparse
import importlib
importlib.reload(gffparse)


# In[3]:


import pandas as pd
import numpy as np
from intervaltree import IntervalTree
from ordered_set import OrderedSet
from tqdm.notebook import tqdm


# In[4]:


import subprocess
from pathlib import Path
import traceback
import re
import textwrap
import json
from copy import deepcopy
from collections import defaultdict, Counter
import math
from sys import stdin,stdout,stderr


# ## GFF-ify manual annotation decisions

# In[5]:


df = pd.read_table("post-curation/ready.tsv")


# In[6]:


df


# In[7]:


def gff_path(acc, src, geneID=None):
    """Selects the path on disk based on accession and source, and gene id in the case of the manual cases"""
    if src == "manual":
        return f'manual_annotation/{acc}/{geneID}/output.gff3'
    elif src == "augustus":
        return f'input/{acc}.augustus.gff'
    elif src == "liftoff":
        return f'input/{acc}.liftoff.protonly.gff'
    elif src == "pasa":
        return f'input/{acc}.pasa.fix.gff'
    else:
        raise ValueError(f"invalid source: {src}")


# at6137 is excluded from this notebook section, and we treat all 6137 genes like we do the non-NLRs

# In[8]:


good_accs = ['at6923', 'at6929', 'at7143', 'at8285', 'at9104',
 'at9336', 'at9503', 'at9578', 'at9744', 'at9762', 'at9806',
 'at9830', 'at9847', 'at9852', 'at9883', 'at9900', 'at9879']
all_accs = good_accs + ["at6137"]


# The horrible dictionarisaion of everything. takes ~2 mins so if the notebook hangs it's probably doing this.

# Now, we break up the GFFs above into the loci defined in the decisions file.

# In[9]:


loci = {acc: {} for acc in good_accs}
for i, gene in df.iterrows():
    if gene.accession not in loci:
        continue
    if gene.chromosome not in loci[gene.accession]:
        loci[gene.accession][gene.chromosome] =  {strand: IntervalTree() for strand in "+-"}
    try:
        loci[gene.accession][gene.chromosome][gene.strand][gene.locus_start:gene.locus_end] = gene.locus_name
    except KeyError:
        print(gene)
        raise


# In[10]:


srcs = ["augustus", "liftoff", "pasa"]#, "happy"]
locus_gffs = { acc: { src: defaultdict(list) for src in srcs} for acc in good_accs}
all_lids = defaultdict(set)
for acc in good_accs:
    for src in srcs:
        i = 0
        if src == "happy":
            gff_data = gffparse.gff_heirarchy(f"output/{acc}_happy.gff3", progress=f"{acc} {src}")
        else:
            gff_data = gffparse.gff_heirarchy(gff_path(acc, src), progress=f"{acc} {src}")
        for gene, gene_data in gff_data.items():
            try:
                locus = loci[acc][gene_data["seqid"]][gene_data["strand"]].overlap(gene_data["start"], gene_data["end"])
            except KeyError:
                continue
            if len(locus) > 0:
                i +=  1
                locus_ids = [l.data for l in locus]
                for lid in locus_ids:
                    locus_gffs[acc][src][lid].append(gene_data)
                    all_lids[acc].add(lid)
        print(f"{acc} {src} {i} genes from {src}")


# In[11]:


class GeneProcessor(object):
    def __init__(self, gene):
        self.gene = deepcopy(gene)
        
    def apply(self, function, *args, **kwargs):
        res = function(self.gene, *args, **kwargs)
        if res is not None:
            self.gene = res
        return self


# In[12]:


def rename_parent(gene, frm, to, silent=False):
    gid =  gene["attributes"]["ID"]
    if re.match(frm, gid):
        newid = re.sub(frm, to, gid)
        if not silent:
            print(f"INFO: renaming gene {gid} to {newid}", file=stderr)
        gene['attributes']["ID"] = newid
        children = list(gene["children"].keys())
        for c in children:
            child = gene["children"][c]
            if "Parent" in child["attributes"] and re.match(frm, child["attributes"]["Parent"]):
                child["attributes"]["Parent"] = newid
    return gene


# In[13]:


def update_type(gene, type_updater, exclude_unknown_children=False):
    gid = gene["attributes"]["ID"]
    gene["type"] = type_updater.get(gene["type"], gene["type"])
    if "children" in gene:
        children = list(gene["children"].keys())
        for child in children:
            update_type(gene["children"][child], type_updater)
            if exclude_unknown_children and gene["children"][child]["type"] not in type_updater:
                print(f"WARNING: removing unloved child '{child}' of type {gene['children'][child]['type']} from gene {gid}", file=stdout)
                del gene["children"][child]
            else:
                update_type(gene["children"][child], type_updater)


# In[14]:


def pseudogene_reontologise(gene, loc, exclude_unknown_children=False):
    if not isinstance(loc.pseudogene, str) or not loc.pseudogene:
        return gene
    gid = gene["attributes"]["ID"]
    pseudogene_defs = set([x.strip() for x in loc.pseudogene.split(",")])
    for pseudogene in pseudogene_defs:
        if "_" in pseudogene:
            pseudo, pseudo_id = pseudogene.split("_", 1)
        else:
            pseudo = pseudogene
            pseudo_id = None
        if pseudo == "protopseudogene" and (pseudo_id is None or gid == pseudo_id):
            type_updater = {} # we keep this the same
            attrs = {"is_pseudogenic": "protopseudogene"}
            exclude_unknown_children = False
        elif pseudo == "pseudogene" and (pseudo_id is None or gid == pseudo_id):
            type_updater = {"gene": "pseudogene",
                            "mRNA": "pseudogenic_transcript",
                            "transcript": "pseudogenic_transcript",
                            "CDS": "CDS",
                            "exon": "exon"}
            attrs = {"is_pseudogenic": "pseudogene"}
        elif (pseudo == "remnants" or pseudo == "remnant") and (pseudo_id is None or gid == pseudo_id):
            type_updater = {"gene": "pseudogenic_region",
                            "mRNA": "pseudogenic_transcript",
                            "transcript": "pseudogenic_transcript",
                            "CDS": "CDS",
                            "exon": "exon"}
            attrs = {"is_pseudogenic": "remnants"}
        else:
            if pseudo_id is not None:
                pass
                #print(f"INFO: didn't match gene ID ({gid}) for {pseudogene} for {loc.accession}@{loc.locus_name}", file=stderr)
            else:
                print(f"ERROR: don't know how to deal with {pseudogene} for {loc.accession}@{loc.locus_name}", file=stderr)
            continue
        update_type(gene, type_updater, exclude_unknown_children=exclude_unknown_children)
        gene["attributes"].update(attrs)
    return gene


# In[15]:


def pseudogenise_liftoff_invalid_orfs(gene, loc):
    if gene["source"] != "Liftoff":
        return
    # If the gene has no valid orfs in its mRNAs, then it's a pseudogene. These are pseudogenes, so add a pseudogene entry for this in the loc table.
    # it then gets processed as though we did this manually in the horrible table of doom.
    if int(gene["attributes"].get("valid_orfs", "0")) < 1:
        gid = gene["attributes"]["ID"]
        existing = ""
        if isinstance(loc.pseudogene, str):
            if loc.pseudogene != "pseudogene":
                #print(f"WARNING: locus already has a pseudogene, check for mistakes {loc.chromosome} {loc.locus_name} {loc.pseudogene} liftoff {gid}", file=stdout)
                existing = f",{loc.pseudogene}"
        if loc.pseudogene != "pseudogene":
            loc.pseudogene = f"pseudogene_{gid}{existing}"
            #print(f"INFO: pseudogenise {loc.chromosome} {loc.locus_name} liftoff {gid} -- check for this later, automation said:  {loc.kevin_decision}", file=stdout)
    return gene


# In[16]:


nlrannot = {acc: [] for acc in good_accs}
for i, loc in df.iterrows():
    gff = []
    if loc.accession not in nlrannot:
        continue
    if loc.annotation_source == "do_not_export":
        continue
    elif loc.annotation_source == "manual":
        try:
            gff = list(gffparse.gff_heirarchy(gff_path(loc.accession, loc.annotation_source, geneID=loc.locus_name)).values())
        except Exception as exc:
            if isinstance(exc, FileNotFoundError):
                print(f"NOT READY/no output.gff3: {loc.accession}, {loc.locus_name}")
            elif isinstance(exc, AssertionError):
                print(f"FIELDS:\n{gff_path(loc.accession, loc.annotation_source, geneID=loc.locus_name)}")
            else:
                print(f"FIXME:\n{gff_path(loc.accession, loc.annotation_source, geneID=loc.locus_name)}")
                traceback.print_exc()
    # This disrespects the manual curation of the automated cases. Some automated decisions changed between when the manual curation happened and now, so we always revert to taking what is in the table.
    #elif loc.take_auto == True:
    #    try:
    #        gff = locus_gffs[loc.accession]["happy"][loc.locus_name]
    #    except KeyError as exc:
    #        print(f"WARNING: happy annotation lookup missing: {loc.accession} {loc.locus_name} {loc.annotation_source}")
    #        print(loc)
    #        print(exc)
    else:
        try:
            gff = locus_gffs[loc.accession][loc.annotation_source][loc.locus_name]
        except KeyError as exc:
            print(f"WARNING: auto annotation lookup missing: {loc.accession} {loc.locus_name} {loc.annotation_source}")
            print(loc)
            print(exc)
            
    def check(gene):
        if gene["seqid"] != loc.chromosome:
            print(f"ERROR: unexpected chromosome for  {loc.accession} {loc.locus_name} {loc.annotation_source}: {gene['seqid']} != {loc.chromosome}", file=stderr)
        gene["attributes"]["manually_curated_dl20"] = "true"
        gene["attributes"]["manual_curation_locus_id"] = loc.locus_name
        if "confidence_reason" not in gene["attributes"]:
            if not pd.isna(loc.kevin_decision):
                gene["attributes"]["confidence_reason"] =  loc.kevin_decision
            else:
                gene["attributes"]["confidence_reason"] =  "manual_post_curation"
    gff = [
        (GeneProcessor(gene)
         .apply(check)
         .apply(pseudogenise_liftoff_invalid_orfs, loc)
         # this renames the type column from protein coding genes to pseudogene, updating the whole annotation ontology tree
         .apply(pseudogene_reontologise, loc, exclude_unknown_children=False)
         # fix a bit of a fuckup, in that we forgot to deduplicate gene names when fixing them with agat after splitting to genes.
         # This was done with a pretty dumb awk script that just kept the two mRNA entries then added the missing L1 parents with
         # agat, but then they all get named like gene1, gene2 for all of these cases, so you have like 12 gene1s and they can do
         # weird things with tools that expect gene IDs to be unique.
         .apply(rename_parent, "(nbisL1-mrna-\\d)", f"{loc.locus_name}_\\1", silent=True)
         .gene
        )
        for gene in gff
    ]
    
    #def get_types(gene):
    #    if "type" in gene:
    #        yield gene["type"]
    #    if "children" in gene:
    #        for child in gene["children"].values():
    #            yield from get_types(child)
    #types = {g["attributes"]["ID"]: list(OrderedSet(get_types(g))) for g in gff}
    #if isinstance(loc.pseudogene, str) and "_" in loc.pseudogene:
    #    for gid, typs in types.items():
    #        pass
    #        print(f"INFO: {loc.accession} {loc.chromosome} {loc.locus_name} {loc.pseudogene} {gid} -> {typs}", file=stdout)
    #        if len(typs) < 2:
    #            for gene in gff:
    #                if gene["attributes"]["ID"] == gid:
    #                    write_gene(gene, file=stdout)
    #        
    nlrannot[loc.accession].extend(gff)


# ## automated annotations of Non-NLRs

# In[17]:


def cdsextent(gene):
    left, right = gene["start"], gene["end"]
    for child in gene["children"].values():
        for gchild in child.get("children", {}).values():
            if gchild["type"] != "CDS":
                continue
            if gchild["start"] < left:
                left = gchild["start"]
            if gchild["end"] > right:
                right = gchild["end"]
    return left, right


# In[18]:


autogff = {acc: [] for acc in all_accs}
for acc in sorted(all_accs):
    nskip = 0
    for gid, gene in tqdm(gffparse.gff_heirarchy(f"output/{acc}_happy.gff3").items()):
        chrom = gene["seqid"]
        if not chrom.startswith(acc):
            print("ERROR:", chrom, "not from", acc, file=stderr)
        try:
            l, r = cdsextent(gene)
            nlrlocus = loci[acc][chrom][gene["strand"]].overlap(l, r)
            if nlrlocus:
                #print(f"INFO: skipping NLR locus handled already: {nlrlocus} {chrom} {gid}")
                nskip += 1
                continue
        except KeyError:
            pass
        autogff[acc].append(gene)
    print(f"Done {acc}, skipped {nskip} NLR overlaps")


# ## Post-processing

# In[19]:


mergedannot = defaultdict(list)
for acc, genes in autogff.items():
    mergedannot[acc].extend(genes)
for acc, genes in nlrannot.items():
    mergedannot[acc].extend(genes)


# In[20]:


def extract_original_ids(gene):
    idre = {
        "Liftoff": r"AT[1-5MC]G\d{5}",
        "transdecoder": r"G\d+",
        "AUGUSTUS": r"g\d+",
        "PASA": r"g\d+",
        "NLR_Annotator": r".+",
    }
    reg = idre.get(gene["source"], r".+")
    orig_id = gene["attributes"]["ID"]
    name = gene["attributes"].get("Name", "")
    
    if re.match(r"g\d+", orig_id) and gene["source"] == "Liftoff":
        # a special case for a few genes taken from omniprot
        gene["source"] = "omniprot"
        gene["attributes"]["original_annotator_id"]=orig_id
        return gene
    m = re.match(reg, gene["attributes"]["ID"])
    if not m:
        m = re.search(reg, name)
    if m:
        orig_id = m.group(0)
        gene["attributes"]["original_annotator_id"]=orig_id
    else:
        print(f"WARNING: no original id for {orig_id} with name {name} and type {gene['source']} on {gene['seqid']}", file=stdout)
    return gene


# In[21]:


def recursively(gene, function, *args, **kwargs):
    function(gene, *args, **kwargs)
    for child in gene.get("children", {}).values():
        recursively(child, function, *args, **kwargs)


# In[22]:


def nonames(gene):
    """Remove Name= from attributes as it's almost always crap, and we have regexed out all the relevant stuff"""
    if "Name" in gene["attributes"]:
        del gene["attributes"]["Name"]


# In[23]:


def rename_sequential(gene, n, prefix=None):
    newid = f"G{n:06d}"
    if prefix:
        newid = f"{prefix}_{newid}"
    gffparse.reformat_names(gene, geneid=newid, changenames=False)


# In[24]:


def transcript_dedup(gene):
    def tx_hash(T):
        info = [T['seqid'], T['source'], T['type'], T['start'], T['end'], T['score'], T['strand'], T["phase"]]
        chld = [tx_hash(c) for c in T.get("children", {}).values()]
        chld.sort()
        info.extend(chld)
        return tuple(info)
    
    transcripts = defaultdict(list)
    for tx in gene["children"].values():
        transcripts[tx_hash(tx)].append(tx)
    children = {}
    for txs in transcripts.values():
        tx = txs[0]
        if len(txs) > 1:
            gid = gene["attributes"]["ID"]
            tids = [t["attributes"]["ID"] for t in txs]
            print(f"WARNING: deduplicating duplicate transcripts in {gid}: {tids}", file=stderr)
            for t in txs:
                print(tx_hash(t))
        children[tx["attributes"]["ID"]] = tx
    gene["children"] = children


# In[25]:


def orig_annotator(gene):
    gene["attributes"]["original_annotator"] = gene["source"]
    gene["source"] = "DL20"


# In[26]:


TE_LOCI = {}
with open("../TE_annotation/TE_annotation/output/final_TE_annotation/merging_by_fam/final_TE_annotation_merged_fam.bed") as bed:
    for line in tqdm(bed):
        fields = line.rstrip().split("\t")
        if len(fields) != 4:
            print(f"WARNING: weird bed line {line.rstrip()}", file=stderr)
        chrom, start, end, ids = fields
        start = int(start)+1
        end = int(end)
        ids = [x.replace("ID=", "") for x in re.split('[,;]', ids) if "ID=" in x]
        if chrom not in TE_LOCI:
            TE_LOCI[chrom] =  IntervalTree()
        TE_LOCI[chrom][start:end] = ids


# In[27]:


TE_GENE_COUNTS = Counter()
def te_genes(gene):
    chrom = gene["seqid"]
    acc = chrom.split("_")[0]
    l, r = gene["start"], gene["end"]
    enveloping_hits = []
    try:
        te_hits = TE_LOCI[chrom].overlap(l, r)
    except KeyError:
        return gene
    for iv in te_hits:
        if iv.begin <= l and iv.end >= r:
            enveloping_hits.append(iv)
    if enveloping_hits:
        if gene["type"] == "gene":
            gene["type"] = "transposable_element_gene"
        gene["attributes"]["te_ids"] = ",".join([x for iv in enveloping_hits for x in iv.data])
        TE_GENE_COUNTS[acc]+= 1
    return gene


# In[28]:


def pick_representative(gene):
    """Pick a representative transcript
   
    Ties are broken in the following order:
    
    - Longest sum of CDS lengths
    - most 5' transcription start site
    - longest sum of exon lengths 
    - shortest overall span of transcript (= shortest introns)
    - lexographic order (assuming a duplicate)
    """
    def mrna_length(transcript, by="exon"):
        length = 0
        for child in transcript["children"].values():
            if child["type"] == by:
                length += child["end"] - child["start"] + 1
        return length
    
    gid = gene["attributes"]["ID"]
    C = gene["children"]
    lens = {}
    for cname, child in gene["children"].items():
        if child["type"] == "mRNA":
            if "valid_orf" in child["attributes"] and child["attributes"]["valid_orf"].lower() != "true":
                # Skip invalid ORFs in Liftoff
                continue
            lens[cname] = mrna_length(child, by="CDS")
    if not lens:
        return
    maxsize = max(lens.values())
    biggestcds = {cid:size for cid, size in lens.items() if size == maxsize}
    
    fiveness = {}
    for cid in biggestcds:
        if gene["strand"] == "+":
            fiveness[cid] = C[cid]["start"] - gene["start"] 
        if gene["strand"] == "-":
            fiveness[cid] = gene["end"] - C[cid]["end"]
    fivemost = min(fiveness.values())
    
    lens = {cid: mrna_length(gene["children"][cid], by="exon")
               for cid in fiveness if fiveness[cid] == fivemost}
    maxsize = max(lens.values())
    biggestexon = {cid:size for cid, size in lens.items() if size == maxsize}
    
    spans = {cid: C[cid]["end"] - C[cid]["start"] for cid in biggestexon}
    minspan = min(spans.values())
    smallest_span = {cid:size for cid, size in spans.items() if size == minspan}
    
    if len(smallest_span) > 1:
        pass
        #print(f"WARNING: Equally-primary genes? {gene['attributes']['ID']}", biggestcds, biggestexon, smallest_span)
        #write_gene(gene, file=stdout)
        
    for pick in list(sorted(smallest_span.keys())):
        gene["children"][pick]["attributes"]["primary_transcript_model"] = "true"
        if len(smallest_span) > 1:
            gene["children"][pick]["attributes"]["primary_transcript_model_tied"] = "true"
        gene["children"][pick]["attributes"]["Name"] = gene["children"][pick]["attributes"]["ID"] + "_PRIMARY"


# In[29]:


def onlyrep(gene):
    gene = deepcopy(gene)
    gene["children"] = {c:v for c, v in gene["children"].items() if v["attributes"].get("primary_transcript_model") == "true"}
    return gene


# In[30]:


def pseudogene_reontologise_general(gene, exclude_unknown_children=False):
    gid = gene["attributes"]["ID"]
    typ = gene["type"]
    if int(gene["attributes"].get("valid_orfs", "1")) < 1:
        # If liftoff has no valid ORFs
        typ = "pseudogene"
    elif len(gffparse.get_all_features(gene, "CDS")) < 1 and gene["type"] == "gene":
        typ =  "remnants"
        
    # Is pseudogenic
    if typ == "gene" or typ == "protopseudogene":
        return
    if typ == "pseudogene":
        type_updater = {"gene": "pseudogene",
                        "mRNA": "pseudogenic_transcript",
                        "transcript": "pseudogenic_transcript",
                        "CDS": "CDS",
                        "exon": "exon"}
        attrs = {"is_pseudogenic": "pseudogene"}
    elif typ == "remnants" or typ == "pseudogenic_region":
        type_updater = {"gene": "pseudogenic_region",
                        "mRNA": "pseudogenic_transcript",
                        "transcript": "pseudogenic_transcript",
                        "CDS": "CDS",
                        "exon": "exon"}
        attrs = {"is_pseudogenic": "remnants"}
        typ = "pseudogenic_region"
    else:
        print("ERROR: not gene or pseudo or remnant", file=stderr)
        attrs ={}
        type_updater = {}
    
    update_type(gene, type_updater, exclude_unknown_children=exclude_unknown_children)
    gene["type"] = typ
    gene["attributes"].update(attrs)
    #print(typ, gene["attributes"].get("valid_orfs"))
    #write_gene(gene, file=stdout)
    return gene


# In[31]:


def sanity_check(gene):
    gid = gene["attributes"]["ID"]
    gene["attributes"]["dl20_export_version"] = EXPORT_VERSION


# In[32]:


for acc, genes in sorted(mergedannot.items()):
    with open(f"post-curation/{acc}_hodgepodgemerged.gff3", "w") as fh, \
         open(f"post-curation/{acc}_hodgepodgemerged.representatives.gff3", "w") as repfh:
        for gene in genes:
            if "seqid" not in gene:
                print(gene)
                break
        for i, gene in tqdm(enumerate(sorted(genes, key=lambda g: (g["seqid"], g["start"], g["attributes"]["ID"]))), desc=acc):
            (
                GeneProcessor(gene)
                # regex the original annotator's ID from either the ID or the Name or give up and don't add it, but warn.
                .apply(extract_original_ids)
                .apply(pseudogene_reontologise_general)
                # extract the original annotator's name (like above)
                .apply(recursively, orig_annotator)
                # remove duplicated transcripts
                # hopefully not needed
                #.apply(transcript_dedup)
                # Remove "Name=" which is mostly horseshit
                .apply(recursively, nonames)
                # rename nicely in order
                .apply(rename_sequential, prefix=acc, n=(i+1)*10)
                # Pick representative gene model
                .apply(pick_representative)
                # Reassign TE genes to type transposible_element_gene
                .apply(te_genes)
                .apply(sanity_check)
                # LAST, write to file
                .apply(gffparse.write_gene, file=fh)
                .apply(onlyrep)
                .apply(gffparse.write_gene, file=repfh)
            )


# In[33]:


for k, v in TE_GENE_COUNTS.most_common():
    print(k, v, sep="\t")


# In[34]:


def igvjs_accession(acc, force_remake_igv=True):
    force_remake_igv=True
    gffls = [
        f"post-curation/{acc}_hodgepodgemerged.gff3",
        f"post-curation/{acc}_hodgepodgemerged.representatives.gff3",
        f'input/{acc}.augustus.gff',
        f'input/{acc}.liftoff.protonly.gff',
        f'input/{acc}.pasa.fix.gff',
        f'input/{acc}.transdecoder.gff'
    ]
    idx_dir = Path(f"post-curation/indexed/{acc}/")
    if not idx_dir.is_dir():
        idx_dir.mkdir(parents=True)
    gffidxd = []
    for gff in gffls:
        gff = Path(gff)
        if not gff.exists():
            continue
        bn = Path(gff).name
        if bn.endswith("gff"):
            bn = bn + "3"
        out = idx_dir / bn
        outgz = idx_dir / f"{bn}.gz"
        outtbi = idx_dir / f"{bn}.gz.tbi"
        gffidxd.append(str(outgz))
        if not outtbi.exists() or force_remake_igv:
            if "transdecoder" in str(gff):
                regex = r"(.+\t){8}.+"
                subprocess.run(f"grep -P '{regex}' {gff} >tmp/{bn}.fixtmp.gff3", shell=True, check=True)
                gff = f"tmp/{bn}.fixtmp.gff3"
            if "hodgepodge" in str(gff):
                subprocess.run(f"conda activate dl20; rm -f tmp/{bn}.agatted.gff3; agat_convert_sp_gxf2gxf.pl --config input/agat_config.yaml -g {gff} -o tmp/{bn}.agatted.gff3 &>tmp/{bn}.agatted.gff3.log", shell=True, check=True, executable="/bin/bash")
                gff = f"tmp/{bn}.agatted.gff3"
                
            subprocess.run(f"grep -v '^#' {gff} | sort -s -k 1,1 -k 4,4n -o {out}", shell=True, check=True)
            subprocess.run(f"bgzip --stdout --index --index-name {outgz}.gzi --compress-level 9 --threads 8 {out} >{outgz}", shell=True, check=True)
            subprocess.run(f"tabix {outgz}", shell=True, check=True)
            print(f"tabix {bn}")
        else:
            print(f"{bn} done")
    
    igv_dir = Path(f"post-curation/igv/{acc}")
    igv_dir.parent.mkdir(parents=True, exist_ok=True)
    
    fasta = Path(f"../assembly-and-annotation/output/01_assembly/03_inversion_fixed/{acc}.fasta")
    subprocess.run(f"blsl genigvjs --reference {fasta} --outdir {igv_dir} {' '.join(gffidxd)} output/{acc}_decisions.bed ../TE_annotation/TE_annotation/output/final_TE_annotation/merging_by_fam/final_TE_annotation_merged_fam.bed", shell=True, check=True)
    print(f"IGV for {acc}")
    return acc


# In[35]:


import multiprocessing
with multiprocessing.Pool(20) as pool:
    for x in pool.imap(igvjs_accession, all_accs):
        print(f"{x} Done!")


# In[36]:


get_ipython().system(' bash post-curation/sync2dviz.sh')


# In[37]:


get_ipython().system(' ssh root@d6dataviz chown -R root:www-data /data/www/dl20')


# In[ ]:




