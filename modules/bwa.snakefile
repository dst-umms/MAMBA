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

rule build_index:
  input:
    refFasta = "analysis/roary/core_genome.fasta"
  output:
    refDone = "analysis/bwa/index/ref.done"
  params:
    prefix = "analysis/bwa/index/ref"
  shell:
    "bwa index -p {params.prefix} {input.refFasta} "
    "&& touch {output.refDone} "

rule bwa_align:
  input:
    buildRef = "analysis/bwa/index/ref.done",
    fastqs = lambda wildcards: config["isolates"][wildcards.sample]
  output:
    samFile = "analysis/bwa/aln/{sample}/{sample}.sam"
  params:
    RGline = lambda wildcards: '@RG\\tID:' + wildcards.sample + '\\tPU:' + \
              wildcards.sample + '\\tSM:' + wildcards.sample + '\\tPL:ILLUMINA' + \
              '\\tLB:' + wildcards.sample
  threads: 8
  shell:
    "bwa mem -t {threads} -R \'{params.RGline}\' analysis/bwa/index/ref {input.fastqs} "
    "1>{output.samFile} "

rule samToBam:
  input:
    "analysis/bwa/aln/{sample}/{sample}.sam"
  output:
    "analysis/bwa/aln/{sample}/{sample}.bam"
  message:
    "Sam to bam coversion"
  shell:
    "samtools view -bS {input} 1>{output}"


rule sortBam:
  input:
    unsortedBam = "analysis/bwa/aln/{sample}/{sample}.bam"
  output:
    sortedBam = "analysis/bwa/aln/{sample}/{sample}.sorted.bam",
    bam_index = "analysis/bwa/aln/{sample}/{sample}.sorted.bam.bai"
  message:
    "Sorting and indexing bam"
  threads: 4
  shell:
    "samtools sort --threads {threads} -o {output.sortedBam} {input.unsortedBam} "
    "&& samtools index {output.sortedBam}"

rule samtoolsStats:
  input:
    unsortedBam = "analysis/bwa/aln/{sample}/{sample}.bam"
  output:
    samStats = "analysis/bwa/aln/{sample}/{sample}.samtools.stats.txt"
  message:
    "Running samtools stats on {wildcards.sample}"
  shell:
    "samtools stats {input.unsortedBam} | grep ^SN | "
    "gawk 'BEGIN {{ FS=\"\t\"; }} {{ print $2,$3; }}' 1>{output.samStats}"

rule picardStats:
  input:
    sortedBam = "analysis/bwa/aln/{sample}/{sample}.sorted.bam",
    refFasta = "analysis/roary/core_genome.fasta"
  output:
    picardStats = "analysis/bwa/aln/{sample}/" + \
                        "{sample}.picard.wgs_metrics.txt"
  message:
    "Running picard wgs stats on {wildcards.sample}"
  shell:
    "picard CollectWgsMetrics I={input.sortedBam} O={output.picardStats} "
    "R={input.refFasta}" 

rule mapReportMatrix:
  input:
    metricsList = expand("analysis/bwa/aln/{sample}/" + \
                "{sample}.samtools.stats.txt", sample = config["isolates"].keys())
  output:
    csv = "analysis/bwa/aln/align_report.csv"
  message:
    "Gather samtools stats into csv"
  run:
    argList = " -s " + " -s ".join(input.metricsList)
    shell("perl MAMBA/scripts/"
        + "/sam_stats_matrix.pl " + argList + " 1>{output.csv}") 
        
rule mapReportPlot:
  input:
    csv = "analysis/bwa/aln/align_report.csv"
  output:
    png = "analysis/bwa/aln/align_report.png"
  message:
    "Plotting alignment PNG"
  shell:
    "{config[Rscript]} MAMBA/scripts/"
    "sam_stats_matrix.R {input.csv} {output.png}" 
