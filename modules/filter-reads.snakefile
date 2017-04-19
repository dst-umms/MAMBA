#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Filter FastQ reads based on quality score

  Currently we are using Trimmomatic for this.
"""

def getFastq(wildcards):
  return config["isolates"][wildcards.sample]

rule run_trim_pe:
  input:
    getFastq
  output:
    leftPaired = protected("analysis/trimmomatic/{sample}/{sample}.left.paired.fastq.gz"),
    rightPaired = protected("analysis/trimmomatic/{sample}/{sample}.right.paired.fastq.gz"),
    leftUnpaired = protected("analysis/trimmomatic/{sample}/{sample}.left.unpaired.fastq.gz"),
    rightUnpaired = protected("analysis/trimmomatic/{sample}/{sample}.right.unpaired.fastq.gz"),
    trimLog = protected("analysis/trimmomatic/{sample}/{sample}.trim.log")
  params:
    adapterFile = "microbe-tracker/static/adapters.fa"
  threads: 4
  shell:
    "trimmomatic PE -threads {threads} {input} {output.leftPaired} {output.leftUnpaired} \
    {output.rightPaired} {output.rightUnpaired} \
    ILLUMINACLIP:{params.adapterFile}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36 >&{output.trimLog}"
