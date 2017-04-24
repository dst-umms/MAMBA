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

def updateConfig(config):
  if not "skip_gatk_check" in config:
    _checkForGATK(config)
  config = _addExecPaths(config)
  return config

def _addExecPaths(config):
  conda_root = subprocess.check_output('conda info --root', shell = True).decode('utf-8').strip()
  conda_path = os.path.join(conda_root, 'pkgs')
  config["R"] = os.path.join(conda_root, 'envs', 'MAMBA_R', 'bin', 'R')
  config["Rscript"] = os.path.join(conda_root, 'envs', 'MAMBA_R', 'bin', 'Rscript')
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
