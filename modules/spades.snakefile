#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Perform SPAdes denovo assembly per isolate


"""

def getFastq(wildcards):
  return config["isolates"][wildcards.sample]

rule contig_assembly:
  input:
    getFastq
  output:
    protected("analysis/spades/{sample}/contigs.fasta")
  threads: 12
  resources: mem = 20000 #20G
  params:
    outdir = lambda wildcards: "analysis/spades/" + wildcards.sample
  run:
    mem = resources["mem"]
    mem = int(mem / 1000) 
    shell("spades.py -1 {input[0]} -2 {input[1]} -t {threads} -m {mem} -o {params.outdir}")
    
