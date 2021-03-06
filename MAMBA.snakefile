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
  4)  Core genome analysis using Roary
  5)  Alignment of reads to annotated core-genome and/or ref-genome using BWA MEM
  6)  Fasta to VCF to fasta using Pilon.
  7)  MAximum-likelihood-Method Based phylogeny tree-build using RAxML
  8)  Visualization of clusters using Graphlan and SNPRelate.
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
include: "modules/pilon.snakefile"
include: "modules/snprelate.snakefile"
include: "modules/raxml.snakefile"
include: "modules/graphlan.snakefile"

