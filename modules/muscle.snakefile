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

rule multi_fasta_align:
  input:
    "analysis/snp2fa/snps.fasta"
  output:
    "analysis/snp2fa/snps.aln.fasta"
  resources: mem = config["max_mem"]
  message: "INFO: Multi Fasta Alignment using MUSCLE."
  shell:
    "source activate MAMBA_PY2 "
    "&& muscle -in {input} -out {output}" 
