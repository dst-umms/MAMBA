#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 10, 2017"

"""
  Generate Graphlan Annotation

"""

import sys
import pandas as pd

def getMeta(metaFile):
  df = pd.read_csv(metaFile, sep = ",", header = 0, index_col = 0)
  df["color_code"] = ['#5696BC' if df["Group"][index] == "Reference" else '#E04836' 
                        for index in df.index]
  return df

def printMeta(info, ref, out):
  ofh = open(out, "w")
  with open(ref, "r") as fh:
    for line in fh:
      ofh.write(line)

  for sampleName in info.index:
    color = info["color_code"][sampleName]
    ofh.write(sampleName + "\t" + "clade_marker_color" + "\t" + color + "\n")
    ofh.write(sampleName + "\t" + "clade_marker_size" + "\t" + str(20) + "\n")

  ofh.close()


if __name__ == "__main__":
  metaFile = sys.argv[1]
  annotRef = sys.argv[2]
  annotOut = sys.argv[3]
  metaInfo = getMeta(metaFile)
  printMeta(metaInfo, annotRef, annotOut)

