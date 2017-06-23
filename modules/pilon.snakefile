#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 24, 2017"

"""
  Preprocess rules to get to GATK Haplotype Caller


"""

def getRefFasta(wildcards):
  try:
    if wildcards.method == "core_based":
      return 'analysis/core_based/roary/core_genome.fasta'
    else:
      return config['reference']
  except(AttributeError):
    pass
  if wildcards.genome == 'analysis/core_based/roary/core_genome':
    return "analysis/core_based/roary/core_genome.fasta"
  else:
    return config["reference"]

def getDictFile(wildcards):
  if wildcards.method == "core_based":
    return 'analysis/core_based/roary/core_genome.dict'
  else:
    ref_dict = config['reference'].replace('\.fasta', '\.dict')
    ref_dict = ref_dict.replace('\.fna', '\.dict')
    ref_dict = ref_dict.replace('\.fa', '\.dict')
    return ref_dict

rule prepare_ref_fasta:
  input:
    refFasta = getRefFasta
  output:
    dictFile = "{genome}.dict"
  resources: mem = config["med_mem"]
  message: "INFO: Creating dict file for genome."
  shell:
    "samtools faidx {input.refFasta} "
    "&& export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& picard CreateSequenceDictionary REFERENCE={input.refFasta} "
    "OUTPUT={output.dictFile} "

rule run_pilon:
  input:
    sorted_bam = lambda wildcards: "analysis/" + wildcards.method + "/bwa/aln/" +
                  wildcards.sample + "/" + wildcards.sample + ".sorted.bam",
    ref_fasta = getRefFasta
  output:
    vcf_file = "analysis/{method}/pilon/{sample}/{sample}.vcf"
  resources: mem = config["med_mem"]
  message: "INFO: Performing Pilon for {wildcards.method} on sample: {wildcards.sample}."
  params: 
    sample = lambda wildcards: wildcards.sample,
    method = lambda wildcards: wildcards.method,
    read_depth = 10
  threads: config["max_cores"]
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources[mem]}m -Xmx{resources[mem]}m\" "
    "&& pilon --genome {input.ref_fasta} --bam {input.sorted_bam} --output {params.sample} "
    "--outdir analysis/{params.method}/pilon/{params.sample} --vcf --fix snps --threads {threads} "
    "--mindepth {params.read_depth} "

rule fetch_snps:
  input:
    refFasta = getRefFasta,
    dictFile = getDictFile,
    rawVCF = lambda wildcards: "analysis/" + wildcards.method + "/pilon/" +
                    wildcards.sample + "/" + wildcards.sample + ".vcf"
  output:
    snpFile = "analysis/{method}/pilon/{sample}/{sample}.snps.vcf"
  threads: config["max_cores"]
  resources: mem = config["max_mem"]
  message: "INFO: Extracting SNPs from pilon vcf for {wildcards.method} for sample: {wildcards.sample}."
  shell:
    "export _JAVA_OPTIONS=\"-Xms{resources.mem}m -Xmx{resources.mem}m\" "
    "&& gatk -T SelectVariants -R {input.refFasta} -V {input.rawVCF} "
    "-nt {threads} -selectType SNP -o {output.snpFile} "

rule filter_snps:
  input:
    snpFile = lambda wildcards: "analysis/" + wildcards.method + "/pilon/" +
                wildcards.sample + "/" + wildcards.sample + ".snps.vcf"
  output:
    filteredSNP = "analysis/{method}/pilon/{sample}/{sample}.snps.filtered.vcf"
  message: "INFO: Filtering Pilon generated vcf file for {wildcards.method} for sample: {wildcards.sample}."
  resources: mem = config["med_mem"]
  params:
    read_depth = 10,
    quality_cutoff = 20
  shell:
    "vcffilter -f \"DP > $[{params.read_depth} - 1]\" -f \"QUAL > $[{params.quality_cutoff} - 1]\"  "
    "{input.snpFile} 1>{output.filteredSNP} "

rule get_initial_snp_coords:
  input:
    vcfList = expand("analysis/{method}/pilon/{sample}/{sample}.snps.filtered.vcf",
                      sample = config["isolate_list"], method = lambda wildcards: wildcards.method)
  output:
    snp_coord_file = "analysis/{method}/pilon/snp.initial.coord.txt"
  resources: mem = config["min_mem"]
  message: "INFO: Processing vcf files to get initial SNP coordinates from all samples for {wildcards.method}."
  shell:
    "grep -hv '^#' {input.vcfList} | gawk '{{ print $2; }}' | "
    "sort -n | uniq | sort -n 1>{output.snp_coord_file}"

rule get_per_sample_coords:
  input:
    vcf_file = lambda wildcards: "analysis/" + wildcards.method + "/pilon/" +
                wildcards.sample + "/" + wildcards.sample + ".vcf",
    coord_file = lambda wildcards: "analysis/" + wildcards.method + "/pilon/snp.initial.coord.txt"
  output:
    sample_coord_file = "analysis/{method}/pilon/{sample}/{sample}.coord.txt"
  resources: mem = config["med_mem"]
  message: "INFO: Processing snp coord info for {wildcards.method} for sample: {wildcards.sample}."
  shell:
    "perl MAMBA/scripts/filter_snp_coords.pl --coordfile {input.coord_file} "
    "--vcffile {input.vcf_file} 1>{output.sample_coord_file} "


rule get_final_snp_coords:
  input:
    coord_list = expand("analysis/{method}/pilon/{sample}/{sample}.coord.txt",
                  sample = config["isolate_list"], method = lambda wildcards: wildcards.method)
  output:
    snp_coord_file = "analysis/{method}/pilon/snp.final.coord.txt"
  resources: mem = config["med_mem"]
  message: "INFO: Filtering common snps across all samples for {wildcards.method}."
  params: sample_count = len(config["isolate_list"])
  shell:
    "cat {input.coord_list} | sort -n | uniq -c | "
    "gawk -v num={params.sample_count} \'{{ if($1 >= num) {{ print $2; }}}}\' "
    "1>{output.snp_coord_file} "

rule subset_vcf:
  input:
    vcf_file = lambda wildcards: "analysis/" + wildcards.method + "/pilon/" +
                wildcards.sample + "/" + wildcards.sample + ".vcf",
    coord_file = lambda wildcards: "analysis/" + wildcards.method + "/pilon/snp.final.coord.txt"
  output:
    out_vcf_file = "analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf"
  resources: mem = config["med_mem"]
  message: "INFO: Generate subset vcf for {wildcards.method} for sample: {wildcards.sample}."
  shell:
    "perl MAMBA/scripts/print_agg_vcf.pl --vcffile {input.vcf_file} "
    "--coordfile {input.coord_file} 1>{output.out_vcf_file} "

rule snp2fa_per_sample:
  input:
    vcf_file = lambda wildcards: "analysis/" + wildcards.method + "/ref_based/pilon/" +
                wildcards.sample + "/" + wildcards.sample + ".snps.subset.vcf"
  output:
    fa_file = "analysis/{method}/pilon/{sample}/{sample}.snps.fasta"
  resources: mem = config["med_mem"]
  message: "INFO: Converting agg vcf into fasta for {wildcards.method} for sample: {wildcards.sample}."
  params: sample = lambda wildcards: wildcards.sample
  shell:
    "perl MAMBA/scripts/vcf2fa.pl --vcffile {input.vcf_file} --sample {params.sample} "
    "1>{output.fa_file} "

rule snp2fa_aggregate:
  input:
    fa_list = expand("analysis/{method}/pilon/{sample}/{sample}.snps.fasta",
                      sample = config["isolate_list"], method = lambda wildcards: wildcards.method)
  output:
    fa_file = "analysis/{method}/snp2fa/snps.fasta"
  message: "INFO: Generated aggregated fasta file from VCFs for {wildcards.method}."
  resources: mem = config["med_mem"]
  shell:
    "cat {input.fa_list} 1>{output.fa_file} "


