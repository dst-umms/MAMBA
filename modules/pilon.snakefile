#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "June, 22, 2017"

"""
  Run Pilon on sorted bam file to get VCFs

"""

rule run_pilon_Ref:
  input:
    sorted_bam = "analysis/ref_based/bwa/aln/{sample}/{sample}.sorted.bam",
    ref_fasta = config["reference"]
  output:
    vcf_file = "analysis/ref_based/pilon/{sample}/{sample}.vcf"
  resources: mem = config["med_mem"]
  message: "INFO: Performing Pilon on sample: {wildcards.sample}."
  params: sample = lambda wildcards: wildcards.sample
  threads: config["max_cores"]
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources[mem]}m -Xmx{resources[mem]}m\" "
    "&& pilon --genome {input.ref_fasta} --bam {input.sorted_bam} --output {params.sample} "
    "--outdir analysis/ref_based/pilon/{params.sample} --vcf --fix snps --threads {threads} --mindepth 10 "
