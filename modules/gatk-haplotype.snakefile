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
  shell:
    "gatk -T HaplotypeCaller -R {input.refFasta} "
    "-I {input.realignBam} -ploidy 1 -stand_call_conf 30 -o {output.rawVCF} "

rule extract_snps:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    rawVCF = "analysis/variants/{sample}/{sample}.raw.vcf"
  output:
    snpFile = "analysis/variants/{sample}/{sample}.snps.vcf"
  shell:
    "gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-selectType SNP -o {output.snpFile} "

rule extract_indels:
  input:
    refFasta = "analysis/roary/core_genome.fasta",
    rawVCF = "analysis/variants/{sample}/{sample}.raw.vcf"
  output:
    indelFile = "analysis/variants/{sample}/{sample}.indels.vcf"
  shell:
    "gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-selectType INDEL -o {output.indelFile} "

rule filter_snps:
  input:
    snpFile = "analysis/variants/{sample}/{sample}.snps.vcf"
  output:
    filteredSNP = "analysis/variants/{sample}/{sample}.snps.filtered.vcf"
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\"  "
    "{input.snpFile} 1>{output.filteredSNP} "

rule filter_indels:
  input:
    indelFile = "analysis/variants/{sample}/{sample}.indels.vcf"
  output:
    filteredIndel = "analysis/variants/{sample}/{sample}.indels.filtered.vcf"
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\" "
    "{input.indelFile} 1>{output.filteredIndel} "

  
