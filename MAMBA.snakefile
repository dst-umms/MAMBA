#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  MAMBA - MAximum-likelihood-Method Based microbial Analysis

  Have workflow divided into several modules
  1)  Filter FastQ reads based on quality score using Trimmomatic
  2)  Perform denovo assembly using SPAdes
  3)  Perform annotation using Prokka
  4)  Pan and core genome analyses using Roary
  5)  Alignment of reads to annotated core-genome using BWA MEM
  6)  GATK Preprocess rules
  7)  Variant calling using GATK HaplotypeCaller
  8)  Use SNPRelate to draw PCA plots using SNPs and generate fasta file from SNPs.
  8)  Generate Multi Align Fasta using MUSCLE
  9)  Max-likelihood phylogeny tree-build using RAxML
  10) Visualization of clusters using Graphlan
"""

from scripts.utils.config_setup import updateConfig
from scripts.utils.get_target_info import getTargetInfo

configfile: "config.yaml"
config = updateConfig(config)

rule target:
  input:
    getTargetInfo(config)

include: "modules/filter-reads.snakefile"
include: "modules/spades.snakefile"   
include: "modules/prokka.snakefile" 
include: "modules/roary.snakefile"
include: "modules/bwa.snakefile"
include: "modules/gatk-preprocess.snakefile"
include: "modules/gatk-haplotype.snakefile"
include: "modules/snprelate.snakefile"
include: "modules/muscle.snakefile"
include: "modules/raxml.snakefile"
include: "modules/graphlan.snakefile"


include: "modules/pilon.snakefile"
