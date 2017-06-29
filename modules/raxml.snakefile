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
    alnFile = lambda wildcards: "analysis/" + wildcards.method + "/snp2fa/snps.fasta"
  output:
    bestTree = "analysis/{method}/raxml/RAxML_bestTree.snps.{method}"
  params:
    outDir = lambda wildcards: "analysis/" + wildcards.method + "/raxml/",
    prefix = lambda wildcards: "snps." + wildcards.method
  resources: mem = config["max_mem"]
  message: "INFO: Running RAxML to generate phylogeny tree in newick format for {wildcards.method}."
  threads: config["max_cores"]
  shell:
    "raxmlHPC-PTHREADS -s {input.alnFile} -m GTRCAT -T {threads} -p 12345 -n {params.prefix} "
    "&& mv RAxML_*.{params.prefix} {params.outDir}/ "
