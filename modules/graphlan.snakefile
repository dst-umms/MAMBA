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
    newickTree = lambda wildcards: "analysis/" + wildcards.method + 
                  "/raxml/RAxML_bestTree.snps." + wildcards.method
  output:
    phyloXML = "analysis/{method}/graphlan/MAMBA_without_annot.xml"
  resources: mem = config["min_mem"]
  message: "INFO: Convert newick to phyloXML format without annotation for {wildcards.method}."
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan_annotate.py {input.newickTree} {output.phyloXML} "

rule generate_tree_annotation:
  input:
    meta = "meta.csv",
    annotRef = "MAMBA/static/annot.txt"
  output:
    annotFinal = "analysis/{method}/graphlan/MAMBA_annot.txt",
    legendPlot = "analysis/{method}/graphlan/MAMBA.legend.png"
  resources: mem = config["min_mem"]
  message: "INFO: Generate annotation to use with graphlan_annotation for {wildcards.method}."
  shell:
    "source activate MAMBA_PY2 "
    "&& python MAMBA/scripts/generate_graphlan_annot.py "
    "{input.meta} {input.annotRef} {output.annotFinal} {output.legendPlot}"

rule add_annot_to_phyloXML:
  input:
    files = lambda wildcards: ["analysis/" + wildcards.method + "/graphlan/MAMBA_without_annot.xml",
                              "analysis/" + wildcards.method + "/graphlan/MAMBA_annot.txt"]
  output:
    xml = "analysis/{method}/graphlan/MAMBA_with_annot.xml"
  resources: mem = config["min_mem"]
  message: "INFO: Generate phylogXML with annotation added for {wildcards.method}."
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan_annotate.py --annot {input.files[1]} "
    "{input.files[0]} {output.xml} "

rule generate_tree_plot:
  input:
    lambda wildcards: "analysis/" + wildcards.method + "/graphlan/MAMBA_with_annot.xml"
  output:
    "analysis/{method}/graphlan/MAMBA.png"
  resources: mem = config["max_mem"]
  message: "INFO: Generate Graphlan plot for {wildcards.method}."
  shell:
    "source activate MAMBA_PY2 "
    "&& graphlan.py --format png --dpi 300 {input} {output} "

