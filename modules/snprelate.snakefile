#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "June, 7, 2017"

"""
  Perform SNPRelate to plot PCA

  1) Plot PCA
  2) Convert SNP to Fasta
"""

rule plot_PCA:
  input:
    mergedVCF = "analysis/variants/MAMBA.snps.filtered.merged.vcf"
  output:
    gdsFile = "analysis/PCA/gds.file"
  resources: mem = config["max_mem"]
  threads: config["max_cores"]
  params: 
    LD_cutoff = 0.2
  message: "INFO: Processing PCA generation step."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/pca_plot.R {input.mergedVCF} "
    "{output.gdsFile} {params.LD_cutoff} {threads} " 
