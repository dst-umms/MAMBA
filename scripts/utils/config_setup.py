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
  config = _addExecPaths(config)
  return config

def _addExecPaths(config):
  conda_root = subprocess.check_output('conda info --root', shell = True).decode('utf-8').strip()
  conda_path = os.path.join(conda_root, 'pkgs')
  config["R"] = os.path.join(conda_root, 'envs', 'r', 'bin', 'r')
  config["Rscript"] = os.path.join(conda_root, 'envs', 'r', 'bin', 'Rscript')
  return config
