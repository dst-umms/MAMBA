#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "June, 7, 2017"

"""
  Perform SNPRelate to plot PCA

  1) Plot PCA
  2) Convert SNP to Fasta
"""

rule bzip_vcfs:
  input:
    vcfFile = lambda wildcards: "analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf".format(
                    method = wildcards.method, sample = wildcards.sample)
  output:
    vcfGz = "analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf.gz"
  resources: mem = config["min_mem"]
  message: "INFO: Bzipping vcf file for {wildcards.method} for sample: {wildcards.sample}."
  shell:
    "bgzip -c {input.vcfFile} 1>{output.vcfGz} "

rule tabix_vcfs:
  input:
    vcfGz = lambda wildcards: "analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf.gz".format(
                    method = wildcards.method, sample = wildcards.sample)
  output:
    tabixFile = "analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf.gz.tbi"
  resources: mem = config["min_mem"]
  message: "INFO: Tabix indexing bzipped vcf file for {wildcards.method} for sample: {wildcards.sample}."
  shell:
    "tabix -p vcf {input.vcfGz} "

rule merge_vcfs:
  input:
    vcfList = lambda wildcards: ["analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf.gz".format(
        method = wildcards.method, sample = sample) for sample in config["isolate_list"]],
    tabixList = lambda wildcards: ["analysis/{method}/pilon/{sample}/{sample}.snps.subset.vcf.gz.tbi".format(
        method = wildcards.method, sample = sample) for sample in config["isolate_list"]]
  output:
    mergedVCF = "analysis/{method}/pilon/snps.subset.merged.vcf"
  resources: mem = config["max_mem"]
  message: "INFO: Merging filtered SNP vcfs for {wildcards.method}."
  run:
    vcf_list = " ".join(input.vcfList)
    sample_list = ",".join(config["isolate_list"])
    shell("vcf-merge {vcf_list} |  \
            perl -e 'my @samples = split(\",\", $ARGV[0]); \
              my @vals = (\"#CHROM\", \"POS\", \"ID\", \"REF\", \"ALT\", \"QUAL\", \"FILTER\", \"INFO\", \"FORMAT\"); \
              my @header = (@vals, @samples); \
              while(my $line = <STDIN>) {{ \
                if(substr($line, 0, 6) eq \"#CHROM\") {{ \
                  print join(\"\\t\", @header), \"\\n\"; \
                }} else {{ \
                  print $line; \
                }} \
              }}' {sample_list} 1>{output.mergedVCF} ")

rule plot_PCA:
  input:
    mergedVCF = lambda wildcards: "analysis/{method}/pilon/snps.subset.merged.vcf".format(method = wildcards.method),
    metaFile = "meta.csv"
  output:
    gdsFile = "analysis/{method}/pca/gds.file",
    pdfFile = "analysis/{method}/pca/pca.pdf",
    snpDataFile = "analysis/{method}/pca/snpset.Rdmpd",
    pcaDataFile = "analysis/{method}/pca/pca.Rdmpd"
  resources: mem = config["max_mem"]
  threads: config["max_cores"]
  params: 
    LD_cutoff = 0.2
  message: "INFO: Processing PCA generation step for {wildcards.method}."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/pca_plot.R {input.mergedVCF} {input.metaFile} "
    "{output.gdsFile} {output.pdfFile} {output.snpDataFile} {params.LD_cutoff} {threads} "
    "{output.pcaDataFile} "


rule snp2fa:
  input:
    gdsFile = lambda wildcards: "analysis/{method}/pca/gds.file".format(method = wildcards.method),
    snpDataFile = lambda wildcards: "analysis/{method}/pca/snpset.Rdmpd".format(method = wildcards.method)
  output:
    faFile = "analysis/{method}/pca/snps.fasta",
    idFile = "analysis/{method}/pca/snps.ids.txt"
  resources: mem = config["max_mem"]
  message: "INFO: Processing SNP to fasta using SNPRelate for {wildcards.method}."
  shell:
    "source activate MAMBA_R "
    "&& Rscript MAMBA/scripts/snp2fa.R {input.gdsFile} {input.snpDataFile} "
    " {output.faFile} {output.idFile} " 


