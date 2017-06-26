#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 23, 2017"

"""
  Perform alignment using BWA MEM

  Takes in reference fasta and aligns
  short reads to built ref genome index.
"""

def getFastq(wildcards):
  return ["analysis/trimmomatic/{sample}/{sample}.left.paired.fastq.gz".format(sample = wildcards.sample),
          "analysis/trimmomatic/{sample}/{sample}.right.paired.fastq.gz".format(sample = wildcards.sample)]

def getRefFasta(wildcards):
  if wildcards.method == 'core_based':
    return "analysis/core_based/roary/core_genome.fasta"
  else:
    return config["reference"]

rule build_index:
  input:
    refFasta = getRefFasta
  output:
    refDone = "analysis/{method}/bwa/index/ref.done"
  params:
    prefix = lambda wildcards: "analysis/" + wildcards.method + "/bwa/index/ref"
  resources: mem = config["med_mem"]
  message: "INFO: Building BWA index with {wildcards.method} genome."
  shell:
    "bwa index -p {params.prefix} {input.refFasta} "
    "&& touch {output.refDone} "

rule bwa_align:
  input:
    buildRef = lambda wildcards: "analysis/" + wildcards.method + "/bwa/index/ref.done",
    fastqs = getFastq
  output:
    samFile = "analysis/{method}/bwa/aln/{sample}/{sample}.sam"
  params:
    RGline = lambda wildcards: '@RG\\tID:' + wildcards.sample + '\\tPU:' + \
              wildcards.sample + '\\tSM:' + wildcards.sample + '\\tPL:ILLUMINA' + \
              '\\tLB:' + wildcards.sample,
    bwaIndex = lambda wildcards: "analysis/" + wildcards.method + "/bwa/index/ref"
  threads: config["max_cores"]
  resources: mem = config["med_mem"]
  message: "INFO: Processing {wildcards.method} bwa alignment for sample: {wildcards.sample}."
  shell:
    "bwa mem -t {threads} -R \'{params.RGline}\' {params.bwaIndex} {input.fastqs} "
    "1>{output.samFile} "

rule sam2Bam:
  input:
    samFile = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/" +
                wildcards.sample + "/" + wildcards.sample + ".sam"
  output:
    bamFile = "analysis/{method}/bwa/aln/{sample}/{sample}.bam"
  message:
    "INFO: {wildcards.method} - Sam to bam coversion for sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "samtools view -bS {input.samFile} 1>{output.bamFile}"


rule sort_bam:
  input:
    unsortedBam = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/" +
                    wildcards.sample + "/" + wildcards.sample + ".bam"
  output:
    sortedBam = "analysis/{method}/bwa/aln/{sample}/{sample}.sorted.bam",
    bam_index = "analysis/{method}/bwa/aln/{sample}/{sample}.sorted.bam.bai"
  message:
    "INFO: {wildcards.method} - Sorting and indexing bam for sample: {wildcards.sample}."
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  shell:
    "samtools sort --threads {threads} -o {output.sortedBam} {input.unsortedBam} "
    "&& samtools index {output.sortedBam}"

rule samtools_stats:
  input:
    unsortedBam = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/" +
                    wildcards.sample + "/" + wildcards.sample + ".bam"
  output:
    samStats = "analysis/{method}/bwa/aln/{sample}/{sample}.samtools.stats.txt"
  message:
    "INFO: Running samtools stats for {wildcards.method} on sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "samtools stats {input.unsortedBam} | grep ^SN | "
    "gawk 'BEGIN {{ FS=\"\t\"; }} {{ print $2,$3; }}' 1>{output.samStats}"

rule picard_stats:
  input:
    sortedBam = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/" + 
                  wildcards.sample + "/" + wildcards.sample + ".sorted.bam",
    refFasta = getRefFasta
  output:
    picardStats = "analysis/{method}/bwa/aln/{sample}/" + \
                        "{sample}.picard.wgs_metrics.txt"
  message:
    "INFO: Running picard wgs stats for {wildcards.method} on sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& picard CollectWgsMetrics I={input.sortedBam} O={output.picardStats} "
    "R={input.refFasta}" 

rule map_report_matrix:
  input:
    metricsList = lambda wildcards: ["analysis/{method}/bwa/aln/{sample}/{sample}.samtools.stats.txt".format(
                    method = wildcards.method, sample = sample) for sample in config["isolate_list"]]
  output:
    csv = "analysis/{method}/bwa/aln/align_report.csv"
  message:
    "INFO: Gather all samtools stats for {wildcards.method} into csv."
  resources: mem = config["min_mem"]
  run:
    argList = " -s " + " -s ".join(input.metricsList)
    shell("perl MAMBA/scripts/"
        + "/sam_stats_matrix.pl " + argList + " 1>{output.csv}") 
        
rule map_report_plot:
  input:
    csv = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/align_report.csv"
  output:
    png = "analysis/{method}/bwa/aln/align_report.png"
  message:
    "INFO: Plotting alignment stats into PNG."
  resources: mem = config["min_mem"]
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/sam_stats_matrix.R {input.csv} {output.png}" 

