#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Perform SPAdes denovo assembly per isolate


"""

def getFastq(wildcards):
  return ["analysis/trimmomatic/{sample}/{sample}.left.paired.fastq.gz".format(sample = wildcards.sample),
          "analysis/trimmomatic/{sample}/{sample}.right.paired.fastq.gz".format(sample = wildcards.sample)]

rule spades_denovo_assembly:
  input:
    getFastq
  output:
    protected("analysis/core_based/spades/{sample}/contigs.fasta")
  threads: config["med_cores"]
  resources: mem = config["med_mem"]
  params:
    outdir = lambda wildcards: "analysis/core_based/spades/" + wildcards.sample
  message: "INFO: Processing denovo assembly step for sample: {wildcards.sample}."
  run:
    mem = resources["mem"]
    mem = int(mem / 1000) 
    shell("spades.py -1 {input[0]} -2 {input[1]} -t {threads} -m {mem} -o {params.outdir}")
    
