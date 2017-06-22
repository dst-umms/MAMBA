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
    mergedVCF = "analysis/variants/MAMBA.snps.filtered.merged.vcf",
    metaFile = "meta.csv"
  output:
    gdsFile = "analysis/PCA/gds.file",
    pdfFile = "analysis/PCA/PCA.pdf",
    snpDataFile = "analysis/PCA/snpset.Rdmpd"
  resources: mem = config["max_mem"]
  threads: config["max_cores"]
  params: 
    LD_cutoff = 0.2
  message: "INFO: Processing PCA generation step."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/pca_plot.R {input.mergedVCF} {input.metaFile} "
    "{output.gdsFile} {output.pdfFile} {output.snpDataFile} {params.LD_cutoff} {threads} "


rule snp2fa:
  input:
    gdsFile = "analysis/PCA/gds.file",
    snpDataFile = "analysis/PCA/snpset.Rdmpd"
  output:
    faFile = "analysis/snp2fa/snps.fasta",
    idFile = "analysis/snp2fa/snps.ids.txt"
  resources: mem = config["max_mem"]
  message: "INFO: Processing SNP to fasta."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/snp2fa.R {input.gdsFile} {input.snpDataFile} "
    " {output.faFile} {output.idFile} " 


rule plot_PCA_Ref:
  input:
    mergedVCF = "analysis/ref_based/pilon/MAMBA.snps.filtered.merged.vcf",
    metaFile = "meta.csv"
  output:
    gdsFile = "analysis/ref_based/PCA/gds.file",
    pdfFile = "analysis/ref_based/PCA/PCA.pdf",
    snpDataFile = "analysis/ref_based/PCA/snpset.Rdmpd"
  resources: mem = config["max_mem"]
  threads: config["max_cores"]
  params:
    LD_cutoff = 0.2
  message: "INFO: Processing PCA generation step."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/pca_plot.R {input.mergedVCF} {input.metaFile} "
    "{output.gdsFile} {output.pdfFile} {output.snpDataFile} {params.LD_cutoff} {threads} "


rule snp2fa_Ref:
  input:
    gdsFile = "analysis/ref_based/PCA/gds.file",
    snpDataFile = "analysis/ref_based/PCA/snpset.Rdmpd"
  output:
    faFile = "analysis/ref_based/snp2fa/snps.fasta",
    idFile = "analysis/ref_based/snp2fa/snps.ids.txt"
  resources: mem = config["max_mem"]
  message: "INFO: Processing SNP to fasta."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/snp2fa.R {input.gdsFile} {input.snpDataFile} "
    " {output.faFile} {output.idFile} "


