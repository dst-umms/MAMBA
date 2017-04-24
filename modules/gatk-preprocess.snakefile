#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 24, 2017"

"""
  Preprocess rules to get to GATK Haplotype Caller


"""

rule prepare_ref_fasta:
  input:
    refFasta = "analysis/roary/core_genome.fasta"
  output:
    dictFile = "analysis/roary/core_genome.dict"
  shell:
    "samtools faidx {input.refFasta} "
    "&& picard CreateSequenceDictionary REFERENCE={input.refFasta} "
    "OUTPUT={output.dictFile} "

rule mark_dups:
  input:
    sortedBam = "analysis/bwa/aln/{sample}/{sample}.sorted.bam"
  output:
    dedupBam = "analysis/preprocess/{sample}/{sample}.dedup.bam",
    metricsFile = "analysis/preprocess/{sample}/{sample}.metrics.txt"
  shell:
    "picard MarkDuplicates I={input.sortedBam} O={output.dedupBam} "
    "METRICS_FILE={output.metricsFile} "

rule sort_dedup_bam:
  input:
    dedupBam = "analysis/preprocess/{sample}/{sample}.dedup.bam"
  output:
    dedupIndex = "analysis/preprocess/{sample}/{sample}.dedup.bai"
  shell:
    "picard BuildBamIndex INPUT={input.dedupBam} "

rule realign_targets:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    refDict = "analysis/roary/core_genome.dict",
    dedupBam = "analysis/preprocess/{sample}/{sample}.dedup.bam"
  output:
    targetFile = "analysis/preprocess/{sample}/{sample}.target_intervals.list"
  shell:
    "gatk -T RealignerTargetCreator -R {input.refFasta} -I {input.dedupBam} "
    "-o {output.targetFile} "

rule realign_indels:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    dedupBam = "analysis/preprocess/{sample}/{sample}.dedup.bam",
    targetFile = "analysis/preprocess/{sample}/{sample}.target_intervals.list"
  output:
    realignBam = "analysis/preprocess/{sample}/{sample}.realign.bam"
  shell:
    "gatk -T IndelRealigner -R {input.refFasta} -I {input.dedupBam} "
    "-targetIntervals {input.targetFile} -o {output.realignBam} "


