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
  threads: config["med_cores"]
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
  threads: config["med_cores"]
  resources: mem = config["med_mem"]
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
    vcfFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf"
  output:
    vcfGz = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf.gz"
  resources: mem = config["min_mem"]
  message: "INFO: Bzipping vcf file for sample: {wildcards.sample}."
  shell:
    "bgzip -c {input.vcfFile} 1>{output.vcfGz} "

rule tabix_vcfs_pilon:
  input:
    vcfGz = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf.gz"
  output:
    tabixFile = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf.gz.tbi"
  resources: mem = config["min_mem"]
  message: "INFO: Tabix indexing bzipped vcf file for sample: {wildcards.sample}."
  shell:
    "tabix -p vcf {input.vcfGz} "

rule merge_vcfs_pilon:
  input:
    vcfList = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf.gz",
                      sample = config["isolate_list"]),
    tabixList = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf.gz.tbi",
                      sample = config["isolate_list"])
  output:
    mergedVCF = "analysis/ref_based/pilon/MAMBA.snps.filtered.merged.vcf"
  resources: mem = config["med_mem"]
  message: "INFO: Merging filtered SNP vcfs"
  shell:
    "vcf-merge {input.vcfList} 1>{output.mergedVCF} "

rule get_snp_coords_ref:
  input:
    vcfList = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.filtered.vcf",
                      sample = config["isolate_list"])
  output:
    snp_coord_file = "analysis/ref_based/pilon/snp.coord.txt"
  resources: mem = config["min_mem"]
  message: "INFO: Processing vcf files to get SNP coordinates from all samples."
  shell:
    "grep -hv '^#' {input.vcfList} | gawk '{{ print $2; }}' | "
    "sort -n | uniq | sort -n 1>{output.snp_coord_file}"

rule get_per_sample_coords_ref:
  input:
    vcf_file = "analysis/ref_based/pilon/{sample}/{sample}.vcf",
    coord_file = "analysis/ref_based/pilon/snp.coord.txt"
  output:
    sample_coord_file = "analysis/ref_based/pilon/{sample}/{sample}.coord.txt"
  resources: mem = config["med_mem"]
  message: "INFO: Processing snp coord info for sample: {wildcards.sample}."
  shell:
    "perl MAMBA/scripts/filter_snp_coords.pl --coordfile {input.coord_file} "
    "--vcffile {input.vcf_file} 1>{output.sample_coord_file} "


rule get_snp_coords_agg_ref:
  input:
    coord_list = expand("analysis/ref_based/pilon/{sample}/{sample}.coord.txt",
                  sample = config["isolate_list"])
  output:
    agg_coord_file = "analysis/ref_based/pilon/snp.coord.filtered.txt"
  resources: mem = config["med_mem"]
  message: "INFO: Filtering common snps across all samples."
  params: sample_count = len(config["isolate_list"])
  shell:
    "cat {input.coord_list} | sort -n | uniq -c | "
    "gawk -v num={params.sample_count} \'{{ if($1 > num) {{ print $2; }}}}\' "
    "1>{output.agg_coord_file} "


rule filtered_snp_vcf_ref:
  input:
    vcf_file = "analysis/ref_based/pilon/{sample}/{sample}.vcf",
    coord_file = "analysis/ref_based/pilon/snp.coord.filtered.txt"
  output:
    out_vcf_file = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf"
  resources: mem = config["med_mem"]
  message: "INFO: Generate agg vcf for sample: {wildcards.sample}."
  shell:
    "perl MAMBA/scripts/print_agg_vcf.pl --vcffile {input.vcf_file} "
    "--coordfile {input.coord_file} 1>{output.out_vcf_file} "

rule snp2fa_sample_ref:
  input:
    vcf_file = "analysis/ref_based/pilon/{sample}/{sample}.snps.agg.vcf"
  output:
    fa_file = "analysis/ref_based/pilon/{sample}/{sample}.snps.fa"
  resources: mem = config["med_mem"]
  message: "INFO: Converting agg vcf into fasta for sample: {wildcards.sample}."
  params: sample = lambda wildcards: wildcards.sample
  shell:
    "perl MAMBA/scripts/vcf2fa.pl --vcffile {input.vcf_file} --sample {params.sample} "
    "1>{output.fa_file} "

rule snp2fa_agg_ref:
  input:
    fa_list = expand("analysis/ref_based/pilon/{sample}/{sample}.snps.fa",
                      sample = config["isolate_list"])
  output:
    fa_file = "analysis/ref_based/pilon/vcf2fa.fasta"
  message: "INFO: Generated aggregated fasta file from VCFs."
  resources: mem = config["med_mem"]
  shell:
    "cat {input.fa_list} 1>{output.fa_file} "
