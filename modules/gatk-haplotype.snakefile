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
  threads: 12
  resources: mem = 30000 #30 GB of memory or whatever is available
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
  threads: 12
  resources: mem = 30000 #30 GB of memory
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
  threads: 12
  resources: mem = 30000 #30 GB of memory
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-nt {threads} -selectType INDEL -o {output.indelFile} "

rule filter_snps:
  input:
    snpFile = "analysis/variants/{sample}/{sample}.snps.vcf"
  output:
    filteredSNP = "analysis/variants/{sample}/{sample}.snps.filtered.vcf"
  resources: mem = 5000 #5G
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\"  "
    "{input.snpFile} 1>{output.filteredSNP} "

rule filter_indels:
  input:
    indelFile = "analysis/variants/{sample}/{sample}.indels.vcf"
  output:
    filteredIndel = "analysis/variants/{sample}/{sample}.indels.filtered.vcf"
  resources: mem = 5000 #5G
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\" "
    "{input.indelFile} 1>{output.filteredIndel} "

  
