#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 2, 2017"

"""
  Insilico FastQ Generation

  Generate fastq reads insilico from ref genomes
  provided. Used Grinder to generate raw fastQs
  and deinterleave them using custom python code.
"""

import glob

def prepareConfig(config):
  if "grinder_path" not in config:
    config["grinder_path"] = "grinder"
  if "ref_path" not in config:
    config["ref_path"] = "./"
  if "grinder_args" not in config:
    config["grinder_args"] = ""
  return config

def getSamples(absPath):
  fastaFiles = glob.glob(absPath + "/*fna.gz", recursive = False)
  return {fastaFile.replace(".fna.gz", "") for fastaFile in fastaFiles}


config = prepareConfig(config)
config["samples"] = list(getSamples(config))

rule all:
  input:
    expand("analysis/ref_genomes/insilico/{sample}/{sample}_R1.fastq.gz", sample = config["samples"]),
    expand("analysis/ref_genomes/insilico/{sample}/{sample}_R2.fastq.gz", sample = config["samples"])

rule run_grinder:
  input:
    refFasta = "{config[ref_path]/{sample}.fna.gz"
  output:
    fastQ = "analysis/ref_genomes/insilico/{sample}/{sample}-reads.fastq"
  resources: mem = 10000 #10GB
  params:
    prefix = lambda wildcards: wildcards.sample,
    outDir = lambda wildcards: "analysis/ref_genomes/insilico/" + wildcards.sample
  shell:
    "zcat {input.refFasta} | "
    "perl config[grinder_path] -reference_file - "
    "-base_name {params.prefix} "
    "-output_dir {params.outDir "
    "config[grinder_args] "





