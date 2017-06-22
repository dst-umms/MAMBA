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

rule prepare_ref_fasta_pilon:
  input:
    refFasta = config["reference"]
  output:
    dictFile = config["reference"] + ".dict"
  resources: mem = config["med_mem"]
  message: "INFO: Creating dict file for reference genome."
  shell:
    "samtools faidx {input.refFasta} "
    "&& export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& picard CreateSequenceDictionary REFERENCE={input.refFasta} "
    "OUTPUT={output.dictFile} "

rule filter_snps_pilon:
  input:
    refFasta = config["reference"],
    dictFile = config["reference"] + ".dict",
    rawVCF = "analysis/ref_based/pilon/{sample}/{sample}.vcf"
  output:
    snpFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.vcf"
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  message: "INFO: Extracting SNPs from pilon vcf for sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-nt {threads} -selectType SNP -o {output.snpFile} "
    

rule filter_pilon_ref:
  input:
    snpFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.vcf"
  output:
    filteredSNP = "analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf"
  message: "INFO: Filtering Pilon generated vcf file for sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  shell:
    "vcffilter -f \"DP > 9\" -f \"QUAL > 20\"  "
    "{input.snpFile} 1>{output.filteredSNP} "
   
rule bzip_vcfs_pilon:
  input:
    vcfFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf"
  output:
    vcfGz = "analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf.gz"
  resources: mem = config["min_mem"]
  message: "INFO: Bzipping vcf file for sample: {wildcards.sample}."
  shell:
    "bgzip -c {input.vcfFile} 1>{output.vcfGz} "

rule tabix_vcfs_pilon:
  input:
    vcfGz = "analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf.gz"
  output:
    tabixFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf.gz.tbi"
  resources: mem = config["min_mem"]
  message: "INFO: Tabix indexing bzipped vcf file for sample: {wildcards.sample}."
  shell:
    "tabix -p vcf {input.vcfGz} "

rule merge_vcfs_pilon:
  input:
    vcfList = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf.gz",
                      sample = config["isolate_list"]),
    tabixList = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf.gz.tbi",
                      sample = config["isolate_list"])
  output:
    mergedVCF = "analysis/ref_based/pilon/MAMBA.snps.filtered.merged.vcf"
  resources: mem = config["max_mem"]
  message: "INFO: Merging filtered SNP vcfs"
  shell:
    "vcf-merge {input.vcfList} 1>{output.mergedVCF} "

 
