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
                    _getProkkaOut(config)])
  return targetFiles

def _getTrimOut(config):
  return ["analysis/trimmomatic/trim_report.png"] 

def _getSpadesOut(config):
  return ["analysis/spades/" + sample + "/contigs.fasta" 
    for sample in config["isolates"].keys()]

def _getProkkaOut(config):
  return ["analysis/prokka/" + sample + "/" + sample + ".gbk"
    for sample in config["isolates"].keys()][:1]
