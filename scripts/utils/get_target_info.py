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
  targetFiles.extend(_getTrimOut(config))
  return targetFiles

def _getTrimOut(config):
  return ["analysis/trimmomatic/" + sample + "/" + sample + ".trim.log" 
    for sample in config["isolates"].keys()]
