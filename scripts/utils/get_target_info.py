#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Returns the final list of files wanted by the pipeline

  
"""

def getTargetInfo(config):
  targetFiles = []
  targetFiles.extend([
                        _getTrimOut(config),
                        _getSpadesOut(config),
                        _getProkkaOut(config),
                        _getRoaryOut(config),
                        _getCoreAndAccGenomes(config),
                        _getMapStats(config),
                        _getPilonOut(config),
                        _getPca(config),
                        _getGraphlanPlot(config)
                    ])
  return targetFiles

def _getTrimOut(config):
  return ["analysis/trimmomatic/trim_report.png"] 

def _getSpadesOut(config):
  return ["analysis/core_based/spades/" + sample + "/contigs.fasta" 
    for sample in config["isolate_list"]]

def _getProkkaOut(config):
  return ["analysis/core_based/prokka/" + sample + "/" + sample + ".gbk"
    for sample in config["isolate_list"]]

def _getRoaryOut(config):
  return ["analysis/core_based/roary/roary.done"]

def _getCoreAndAccGenomes(config):
  return ["analysis/core_based/roary/core_genome.tab", "analysis/core_based/roary/accessory_genome.tab"]

def _getMapStats(config):
  return ["analysis/{method}/bwa/aln/align_report.png".format(method = method) 
            for method in config["methods"]]

def _getPilonOut(config):
  return ["analysis/{method}/snp2fa/snps.fasta".format(method = method)
    for method in config["methods"]]

def _getPca(config):
  return ["analysis/{method}/pca/pca.pdf".format(method = method)
    for method in config["methods"]]

def _getGraphlanPlot(config):
  return ["analysis/{method}/graphlan/MAMBA.png".format(method = method)
    for method in config["methods"]]


