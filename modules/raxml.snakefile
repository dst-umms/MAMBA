#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 4, 2017"

"""
  Perform Tree building using RAxML


"""

rule tree_build:
  input:
    alnFile = "analysis/snp2fa/snps.aln.fasta"
  output:
    bestTree = "analysis/raxml/RAxML_bestTree.snps"
  params:
    outDir = "analysis/raxml/"
  resources: mem = config["max_mem"]
  message: "INFO: Running RAxML to generate phylogeny tree in newick format."
  threads: config["max_cores"]
  shell:
    "raxmlHPC-PTHREADS -s {input} -m GTRCAT -T {threads} -p 12345 -n snps "
    "&& mv RAxML_*.snps {params.outDir}/ "
