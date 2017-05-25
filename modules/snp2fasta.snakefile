#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 4, 2017"

"""
  Generate Multi Align Fasta File from VCFs

  Used VCF Kit to generate fasta file from
  VCFs, followed by Muscle - to generate
  multi align fasta file. This will be the 
  input to RAxML program.
"""

rule vcf_to_fasta:
  input:
    expand("analysis/variants/{sample}/{sample}.snps.filtered.vcf", sample = config["isolates"])
  output:
    fastaFile = "analysis/snp2fa/snps.fasta"
  resources: mem = config["max_mem"]
  message: "INFO: Converting VCF to Fasta for sample: " + lambda wildcards: wildcards.sample + "."
  shell:
    "source activate MAMBA_PY2 "
    "&& for file in {input}; do vk phylo fasta $file; done 1>{output.fastaFile} "

rule multi_fasta_align:
  input:
    "analysis/snp2fa/snps.fasta"
  output:
    "analysis/snp2fa/snps.aln.fasta"
  resources: mem = config["max_mem"]
  message: "INFO: Multi Fasta Alignment using MUSCLE."
  shell:
    "source activate MAMBA_PY2 "
    "&& muscle -in {input} -out {output} -maxiters 1 -diags" 
