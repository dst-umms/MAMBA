#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 4, 2017"

"""
  Generate Multi Align Fasta File using MUSCLE

  Generate multi align fasta file. This will be the 
  input to RAxML program.
"""

def get_muscle_params(wildcards):
  if wildcards.method == "ref_based":
    return "-maxiters 1 -diags1"
  else:
    return ""

rule multi_fasta_align:
  input:
    fa = lambda wildcards: "analysis/" + wildcards.method + "/snp2fa/snps.fasta"
  output:
    aln = "analysis/{method}/snp2fa/snps.aln.fasta"
  resources: mem = config["max_mem"]
  message: "INFO: Multi Fasta Alignment using MUSCLE for {wildcards.method}."
  params:
    appx_params = get_muscle_params
  shell:
    "source activate MAMBA_PY2 "
    "&& muscle -in {input.fa} -out {output.aln} {params.appx_params}" 


