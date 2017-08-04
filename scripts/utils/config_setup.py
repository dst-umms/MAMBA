#!/usr/bin/env python
# vim: syntax=python tabstop=2 expandtab

__author__ =  "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 23, 2017"

"""
  Takes config and updates config

  Updates Exec paths et cetera
  important for global pipeline
  execution   
"""

import os, subprocess
import pandas as pd

def updateConfig(config):
  if not "skip_gatk_check" in config:
    _checkForGATK(config)
  return _updateMeta(config)

def _updateMeta(config):
  metadata = pd.read_table(config['metasheet'], index_col = 0, sep = ',', comment = '#')
  config["isolate_list"] = metadata.index
  config["methods"] = ["ref_based", "core_based"] if config["reference"] is not None else ["core_based"]
  return config

def _checkForGATK(config):
  try:
    gatkPresent = subprocess.check_output('gatk --help', shell = True, stderr = subprocess.STDOUT).decode('utf-8').strip()
  except subprocess.CalledProcessError:
    _installGATK(config)

def _installGATK(config):
  if not config["gatk_exec"]:
    print("""
          -----------------   GATK not found   -------------------
          GATK **NOT FOUND** in system PATH. Please provide path to
          GATK tar ball (gz or bz2) in MAMBA.params.yaml or config.yaml
          --------------------------------------------------------
          """)
    sys.exit(1)
  else:
    print("Registering GATK:")
    subprocess.check_output('gatk-register ' + config["gatk_exec"], shell = True).decode('utf-8').strip()
