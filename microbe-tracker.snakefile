#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Microbe-Tracker project pipeline file

  Have workflow divided into several modules
  1) Filter FastQ reads based on quality score
  2) Perform denovo assembly and annotation
  3) Pan and core genome analyses
  4) Alignment of reads to annotated core-genome
  5) Variant calling based on alignment results
  6) Max-likelihood phylogeny tree-build
  7) Visualization of clusters
"""

from scripts.utils.get_target_info import getTargetInfo

configfile: "config.yaml"

rule target:
  input:
    getTargetInfo(config)

include: "modules/filter-reads.snakefile"
    
