#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 24, 2017"

"""
  GATK Haplotype Caller snakefile

  Call variants, separate SNPs and INDELs
  and filter variants using vcffilter
"""

rule call_variants:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    realignBam = "analysis/preprocess/{sample}/{sample}.realign.bam"
  output:
    rawVCF = "analysis/variants/{sample}/{sample}.raw.vcf"
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  message: "INFO: Running HaplotypeCaller on sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T HaplotypeCaller -R {input.refFasta} -nct {threads} "
    "-I {input.realignBam} -ploidy 1 -stand_call_conf 30 -o {output.rawVCF} "

rule extract_snps:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    rawVCF = "analysis/variants/{sample}/{sample}.raw.vcf"
  output:
    snpFile = "analysis/variants/{sample}/{sample}.snps.vcf"
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  message: "INFO: Extracting SNPs for sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-nt {threads} -selectType SNP -o {output.snpFile} "

rule extract_indels:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    rawVCF = "analysis/variants/{sample}/{sample}.raw.vcf"
  output:
    indelFile = "analysis/variants/{sample}/{sample}.indels.vcf"
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  message: "INFO: Extracting INDELs for sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-nt {threads} -selectType INDEL -o {output.indelFile} "

rule filter_snps:
  input:
    snpFile = "analysis/variants/{sample}/{sample}.snps.vcf"
  output:
    filteredSNP = "analysis/variants/{sample}/{sample}.snps.filtered.vcf"
  resources: mem = config["min_mem"]
  message: "INFO: Filtering SNPs for sample: {wildcards.sample}."
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\"  "
    "{input.snpFile} 1>{output.filteredSNP} "

rule filter_indels:
  input:
    indelFile = "analysis/variants/{sample}/{sample}.indels.vcf"
  output:
    filteredIndel = "analysis/variants/{sample}/{sample}.indels.filtered.vcf"
  resources: mem = config["min_mem"]
  message: "INFO: Filtering INDELs for sample: {wildcards.sample}."
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\" "
    "{input.indelFile} 1>{output.filteredIndel} "

rule bzip_vcfs:
  input:
    vcfFile = "analysis/variants/{sample}/{sample}.snps.filtered.vcf"
  output:
    vcfGz = "analysis/variants/{sample}/{sample}.snps.filtered.vcf.gz"
  resources: mem = config["min_mem"]
  message: "INFO: Bzipping vcf file for sample: {wildcards.sample}."
  shell:
    "bgzip -c {input.vcfFile} 1>{output.vcfGz} "

rule tabix_vcfs:
  input:
    vcfGz = "analysis/variants/{sample}/{sample}.snps.filtered.vcf.gz"
  output:
    tabixFile = "analysis/variants/{sample}/{sample}.snps.filtered.vcf.gz.tbi"
  resources: mem = config["min_mem"]
  message: "INFO: Tabix indexing bzipped vcf file for sample: {wildcards.sample}."
  shell:
    "tabix -p vcf {input.vcfGz} "

rule merge_vcfs:
  input:
    vcfList = expand("analysis/variants/{sample}/{sample}.snps.filtered.vcf.gz", 
                      sample = config["isolate_list"]),
    tabixList = expand("analysis/variants/{sample}/{sample}.snps.filtered.vcf.gz.tbi",
                      sample = config["isolate_list"])
  output:
    mergedVCF = "analysis/variants/MAMBA.snps.filtered.merged.vcf"
  resources: mem = config["max_mem"]
  message: "INFO: Merging filtered SNP vcfs"
  shell:
    "vcf-merge {input.vcfList} 1>{output.mergedVCF} "

 
