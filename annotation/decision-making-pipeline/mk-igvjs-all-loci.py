# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.2
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

dl20 = ["at6923", "at6929", "at7143", "at8285", "at9104", "at9336",
        "at9503", "at9578", "at9744", "at9762", "at9806", "at9830", 
        "at9847", "at9852", "at9879", "at9883", "at9900", "at6137", ]

from intervaltree import IntervalTree
from collections import defaultdict, Counter
from gffuuu.gffparse import gff_heirarchy, gffInfoFields
import json
from pprint import pprint
import argparse
import sys
from pathlib import Path
from gffuuuu import write_gene
from shutil import copyfile


def main(acc):
    locibed = f"output/{acc}_decisions.bed"
    loci = defaultdict(lambda: defaultdict(IntervalTree))
    loci_coords = {}
    print("loci at", locibed)
    with open(locibed) as fh: 
        for line in fh:
            fields = line.rstrip().split("\t")
            chr, start, stop, id, _, strand, region, decision = fields
            start = int(start) +1
            stop = int(stop)
            loci[chr][strand][start:stop] = id
            loci_coords[id] = (chr, start, stop, strand)
    print("N loci:", len(loci_coords))

    gffs = {"Augustus": f"input/{acc}.augustus.gff",
            "Liftoff-TAIR10": f"input/{acc}.liftoff.protonly.gff",
            "PASA": f"input/{acc}.pasa.fix.gff",
            "TAMA-v2": f"input/{acc}.tama-v2.fix.gff",
            "Transdecoder": f"/ebio/abt6_projects7/dliso/dlis/leon_pipeline/output/v2/collapse_tama/{acc}_transdecoder/{acc}_transcripts.fasta.transdecoder.genome.cleaned.gff3",
            "NLRannotator": f"../NLRannotator/output/{acc}_nlr_annotator.acutal.gff3",
            "TEs": f"../web_apollo/v2/TEanno/{acc}_TEanno.gff3",
            "PFam": f"../assembly-and-annotation/output/04_analyses_with_fixed_at9879/prep_for_decision_making/{acc}_pfam_acutalgff.gff3",
           } 

    loci_data = defaultdict(lambda : defaultdict(list))
    for src, gff in gffs.items():
        try:
            gff_data = gff_heirarchy(gff)
        except Exception as exc:
            print(exc)
            continue
        i = 0
        for gene, gene_data in gff_data.items():
            locus = loci[gene_data["seqid"]][gene_data["strand"]].overlap(gene_data["start"], gene_data["end"])
            if len(locus) > 0:
                i +=  1
                locus_id = list(locus)[0].data
                loci_data[locus_id][src].append(gene_data)
            else:
                print("NOMATCH:", gene_data)
        print(f"Added {i} genes from {gff} ({len(gff_data) - i} not added)")

    template = """
    <!doctype html>
    <html lang=en>
      <head>
        <meta charset=utf-8>
        <meta name=viewport content="width=device-width,initial-scale=1">
        <meta http-equiv=x-ua-compatible content="IE=edge,chrome=1">
        <title>__title__</title>
        <script src="https://cdn.jsdelivr.net/npm/igv@2.12.6/dist/igv.min.js"></script>
    </head>
    <body>
      <div id="igvherepls"></div>
      <script>
        var igvDiv = document.getElementById("igvherepls");
        var options = __data__;
            igv.createBrowser(igvDiv, options)
                    .then(function (browser) {
                        console.log("Created IGV browser");
                    })
      </script>
    </body>
    """

    infa = Path(f"../assembly-and-annotation/output/01_assembly/03_inversion_fixed/{acc}.fasta")
    outfa = Path("per_locus_igvjs") / acc/ f"{acc}.fasta"
    outfa.parent.mkdir(parents=True, exist_ok=True)
    copyfile(infa, outfa, follow_symlinks=True)
    copyfile(str(infa)+".fai", str(outfa) + ".fai", follow_symlinks=True)

    for loc, srcd in loci_data.items():
        outdir = Path("per_locus_igvjs") / acc / loc 
        lc =loci_coords[loc]
        data = {
            "reference":  {
                "id": acc,
                "name": acc,
                "fastaURL": f"../{acc}.fasta"
            },
            "tracks": [],
            "locus": f"{lc[0]}:{lc[1]}-{lc[2]}",
        }
        col = ['#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6']
        for i, (src, dat) in enumerate(srcd.items()):
            gff = outdir / f"{src}.gff3"
            gff.parent.mkdir(parents=True, exist_ok=True)
            with open(gff, "w") as fh:
                for gene in dat:
                    write_gene(gene, None, file=fh)
            data["tracks"].append({
                "name": src,
                "url": f"./{src}.gff3",
                "format": "gff3",
                "color": col[i],
                "autoHeight": True,
                "minHeight": 50, 
                "maxHeight": 700,
            })
        #data["tracks"].append({
        #    "name": "output",
        #    "url": f"./output.gff3",
        #    "format": "gff3",
        #    "color": col[i+1],
        #    "autoHeight": True,
        #    "minHeight": 50, 
        #    "maxHeight": 700,
        #})

        with open(outdir / "index.html", "w") as fh:
            html = template \
                    .replace("__title__", loc) \
                    .replace("__data__", json.dumps(data))
            fh.write(html)


# + tags=[]
from multiprocessing import Pool
p = Pool(20)
[x for x in p.map(main, dl20)]
# -

# ! genautoindex per_locus_igvjs

# ! tar cf per_locus_igvjs.tar per_locus_igvjs/

# ! ls -lah

# ! pixz
