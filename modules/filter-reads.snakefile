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

rule trimmomatic_PE:
  input:
    getFastq
  output:
    leftPaired = protected("analysis/trimmomatic/{sample}/{sample}.left.paired.fastq.gz"),
    rightPaired = protected("analysis/trimmomatic/{sample}/{sample}.right.paired.fastq.gz"),
    leftUnpaired = protected("analysis/trimmomatic/{sample}/{sample}.left.unpaired.fastq.gz"),
    rightUnpaired = protected("analysis/trimmomatic/{sample}/{sample}.right.unpaired.fastq.gz"),
    trimLog = protected("analysis/trimmomatic/{sample}/{sample}.trim.log")
  params:
    adapterFile = "MAMBA/static/adapters.fa"
  threads: config["max_cores"]
  resources: mem = config["med_mem"]
  message: "INFO: Processing Trimmomatic on sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& trimmomatic PE -threads {threads} {input} {output.leftPaired} {output.leftUnpaired} \
    {output.rightPaired} {output.rightUnpaired} \
    ILLUMINACLIP:{params.adapterFile}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36 >&{output.trimLog}"

rule filtered_reads_QC:
  input:
    trimLogs = expand("analysis/trimmomatic/{sample}/{sample}.trim.log", sample = config["isolate_list"])
  output:
    trimReport = "analysis/trimmomatic/trim_report.csv",
    trimPlot = "analysis/trimmomatic/trim_report.png"
  resources: mem = config["min_mem"]
  message: "INFO: Generating aggregate report with filtered read counts."
  run:
    trimLogList = " -l ".join(input.trimLogs)
    shell("perl MAMBA/scripts/trim_report.pl -l {trimLogList} 1>{output.trimReport}")
    shell("{config[Rscript]} MAMBA/scripts/trim_plot.R {output.trimReport} {output.trimPlot}")
