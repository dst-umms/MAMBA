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
  resources: mem = config["med_mem"]
  message: "INFO: Building BWA index with core genome."
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
  threads: config["max_cores"]
  resources: mem = config["med_mem"]
  message: "INFO: Processing bwa alignment for sample: {wildcards.sample}."
  shell:
    "bwa mem -t {threads} -R \'{params.RGline}\' analysis/bwa/index/ref {input.fastqs} "
    "1>{output.samFile} "

rule sam2Bam:
  input:
    "analysis/bwa/aln/{sample}/{sample}.sam"
  output:
    "analysis/bwa/aln/{sample}/{sample}.bam"
  message:
    "INFO: Sam to bam coversion for sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "samtools view -bS {input} 1>{output}"


rule sort_bam:
  input:
    unsortedBam = "analysis/bwa/aln/{sample}/{sample}.bam"
  output:
    sortedBam = "analysis/bwa/aln/{sample}/{sample}.sorted.bam",
    bam_index = "analysis/bwa/aln/{sample}/{sample}.sorted.bam.bai"
  message:
    "INFO: Sorting and indexing bam for sample: {wildcards.sample}."
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  shell:
    "samtools sort --threads {threads} -o {output.sortedBam} {input.unsortedBam} "
    "&& samtools index {output.sortedBam}"

rule samtools_stats:
  input:
    unsortedBam = "analysis/bwa/aln/{sample}/{sample}.bam"
  output:
    samStats = "analysis/bwa/aln/{sample}/{sample}.samtools.stats.txt"
  message:
    "INFO: Running samtools stats on sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "samtools stats {input.unsortedBam} | grep ^SN | "
    "gawk 'BEGIN {{ FS=\"\t\"; }} {{ print $2,$3; }}' 1>{output.samStats}"

rule picard_stats:
  input:
    sortedBam = "analysis/bwa/aln/{sample}/{sample}.sorted.bam",
    refFasta = "analysis/roary/core_genome.fasta"
  output:
    picardStats = "analysis/bwa/aln/{sample}/" + \
                        "{sample}.picard.wgs_metrics.txt"
  message:
    "INFO: Running picard wgs stats on sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& picard CollectWgsMetrics I={input.sortedBam} O={output.picardStats} "
    "R={input.refFasta}" 

rule map_report_matrix:
  input:
    metricsList = expand("analysis/bwa/aln/{sample}/" + \
                "{sample}.samtools.stats.txt", sample = config["isolate_list"])
  output:
    csv = "analysis/bwa/aln/align_report.csv"
  message:
    "INFO: Gather all samtools stats into csv."
  resources: mem = config["min_mem"]
  run:
    argList = " -s " + " -s ".join(input.metricsList)
    shell("perl MAMBA/scripts/"
        + "/sam_stats_matrix.pl " + argList + " 1>{output.csv}") 
        
rule map_report_plot:
  input:
    csv = "analysis/bwa/aln/align_report.csv"
  output:
    png = "analysis/bwa/aln/align_report.png"
  message:
    "INFO: Plotting alignment stats into PNG."
  resources: mem = config["min_mem"]
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/sam_stats_matrix.R {input.csv} {output.png}" 
