#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 18, 2017"

"""
  Takes in fastq_folder and generates config.yaml

  
"""

import argparse
import os
import yaml
import glob
import re
from collections import OrderedDict

def parseArgs():
  parser = argparse.ArgumentParser()
  parser.add_argument('-f', '--fastq_folder', required = True, help = "Provide an absolute path to folder with FastQs.")
  args = parser.parse_args()
  return args

def orderedLoad(stream, Loader = yaml.Loader, object_pairs_hook = OrderedDict):
  class OrderedLoader(Loader):
    pass

  def construct_mapping(loader, node):
    loader.flatten_mapping(node)
    return object_pairs_hook(loader.construct_pairs(node))
    
  OrderedLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, construct_mapping)
  return yaml.load(stream, OrderedLoader)

def orderedDump(data, stream=None, Dumper=yaml.Dumper, **kwds):
  class OrderedDumper(Dumper):
    pass
    
  def _dict_representer(dumper, data):
    return dumper.represent_mapping(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, data.items())
    
  OrderedDumper.add_representer(OrderedDict, _dict_representer)
  return yaml.dump(data, stream, OrderedDumper, **kwds)


def getFastqInfo(absPath):
  leftmates = glob.glob(absPath + "/*_R1*fast*", recursive = False)
  info = dict()
  info["isolates"] = OrderedDict()
  reObj = re.compile("(\w+?)_R1.+fast*")
  for leftmate in leftmates:
    sample = reObj.search(os.path.basename(leftmate)).group(1)
    rightmate = leftmate.replace("_R1", "_R2")
    if os.path.isfile(rightmate):
      info["isolates"][sample] = [leftmate, rightmate]
    else:
      info["isolates"][sample] = [leftmate]

  return info
    

def getPipelineParams():
  pipelineParamsYaml = "MAMBA/MAMBA.params.yaml"
  with open(pipelineParamsYaml, "r") as fh:
    return orderedLoad(fh, yaml.SafeLoader)

if __name__ == "__main__":
  args = parseArgs()
  info = getPipelineParams()
  fastqInfo = getFastqInfo(args.fastq_folder) 
  info["isolates"] = fastqInfo["isolates"]
  print(orderedDump(info, default_flow_style = False))
