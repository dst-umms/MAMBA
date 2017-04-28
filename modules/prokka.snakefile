#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 20, 2017"

"""
  Takes Spades contigs.fasta and runs Prokka

  Generates NCBI compliant genbank files and 
  gff3 annotation files.
"""

rule contig_annotation:
  input:
    contigFastaFile = lambda wildcards: "analysis/spades/" + wildcards.sample + \
        "/contigs.fasta"
  output:
    genbankFile = "analysis/prokka/{sample}/{sample}.gbk",
    gff3File = "analysis/prokka/{sample}/{sample}.gff"
  params:
    sampleName = lambda wildcards: wildcards.sample,
    kingdom = config["kingdom"] or 'Bacteria',
    genus = config["genus"] or 'Genus',
    species = config["species"] or 'species',
    strain = config["strain"] or 'strain',
    gramCommand = "--gram " + config["gram"] if config["gram"] else ''
  threads: 8
  resources: mem = 10000 #10G
  shell:
    "prokka --outdir analysis/prokka/{params.sampleName} --force "
    "--prefix {params.sampleName} --compliant --centre UMassMedSchool "
    "--genus {params.genus} --species {params.species} --strain {params.strain} "
    "--kingdom {params.kingdom} {params.gramCommand} "
    "--cpus {threads} --mincontiglen 200 {input}"
