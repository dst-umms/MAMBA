#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Perform SPAdes denovo assembly per isolate


"""

rule contig_assembly:
  input:
    getFastq
  output:
    protected("analysis/spades/{sample}/contigs.fasta")
  threads: 12
  resources: mem = 10000 #10G
  params:
    outdir = lambda wildcards: "analysis/spades/" + wildcards.sample
  shell:
    "spades.py -1 {input[0]} -2 {input[1]} -t {threads} -m 10 -o {params.outdir}"
    
