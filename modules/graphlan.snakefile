#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 10, 2017"

"""
  Graphlan module

  Convert RAxML newick tree format to 
  phyloXML format using graphlan_annotation.py
  followed by addition of annotation from 
  meta.csv for clade coloring to addition of
  outer rings to the phylo tree.
"""

rule newick_to_phyloXML:
  input:
    newickTree = "analysis/raxml/RAxML_bestTree.snps"
  output:
    phyloXML = "analysis/graphlan/MAMBA_without_annot.xml"
  resources: mem = 2000 #2G
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan_annotate.py {input.newickTree} {output.phyloXML} "

rule generate_tree_annotation:
  input:
    meta = "meta.csv",
    annotRef = "MAMBA/static/annot.txt"
  output:
    annotFinal = "analysis/graphlan/MAMBA_annot.txt",
    legendPlot = "analysis/graphlan/MAMBA.legend.png"
  resources: mem = 2000 #2G
  shell:
    "source activate MAMBA_PY2 "
    "&& python MAMBA/scripts/generate_graphlan_annot.py "
    "{input.meta} {input.annotRef} {output.annotFinal} {output.legendPlot}"

rule add_annot_to_phyloXML:
  input:
    xml = "analysis/graphlan/MAMBA_without_annot.xml",
    annot = "analysis/graphlan/MAMBA_annot.txt"
  output:
    xml = "analysis/graphlan/MAMBA_with_annot.xml"
  resources: mem = 2000 #2G
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan_annotate.py --annot {input.annot} "
    "{input.xml} {output.xml} "

rule generate_tree_plot:
  input:
    "analysis/graphlan/MAMBA_with_annot.xml"
  output:
    "analysis/graphlan/MAMBA.png"
  resources: mem = 5000 #5G
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan.py --format png --dpi 800 {input} {output} "

