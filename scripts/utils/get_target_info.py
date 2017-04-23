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
  targetFiles.extend([_getTrimOut(config),
                    _getSpadesOut(config),
                    _getProkkaOut(config),
                    _getRoaryOut(config),
                    _getCoreAndAccGenomes(config),
                    _getBWAout(config),
                    _getMapStats(config)])
  return targetFiles

def _getTrimOut(config):
  return ["analysis/trimmomatic/trim_report.png"] 

def _getSpadesOut(config):
  return ["analysis/spades/" + sample + "/contigs.fasta" 
    for sample in config["isolates"].keys()]

def _getProkkaOut(config):
  return ["analysis/prokka/" + sample + "/" + sample + ".gbk"
    for sample in config["isolates"].keys()]

def _getRoaryOut(config):
  return ["analysis/roary/roary.done"]

def _getCoreAndAccGenomes(config):
  return ["analysis/roary/core_genome.tab", "analysis/roary/accessory_genome.tab"]

def _getBWAout(config):
  return ["analysis/bwa/aln/{sample}/{sample}.sam".format(sample = sample)
    for sample in config["isolates"].keys()]

def _getMapStats(config):
  return ["analysis/bwa/aln/align_report.png"]
