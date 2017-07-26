#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 20, 2017"

"""
  Roary snakefile

  Takes in prokka output - gff3 files with
  nucleotide sequences at the end. Generates
  core and pan ganome analyses' output.
"""

rule run_roary:
  input:
    gff3Files = expand("analysis/core_based/prokka/{isolate}/{isolate}.gff", isolate = config["isolate_list"])
  output:
    "analysis/core_based/roary/roary.done",
    "analysis/core_based/roary/clustered_proteins",
    "analysis/core_based/roary/pan_genome_reference.fa"
  threads: config["med_cores"]
  resources: mem = config["med_mem"]
  message: "INFO: Processing roary using all samples."
  shell:
    "roary -p {threads} -cd 95 -f analysis/core_based/roary_tmp -e -n -r {input.gff3Files} "
    "&& mv analysis/core_based/roary_tmp/* analysis/core_based/roary/ && rmdir analysis/core_based/roary_tmp && touch {output[0]}"

rule get_core_genome:
  input:
    gff3Files = expand("analysis/core_based/prokka/{isolate}/{isolate}.gff", isolate = config["isolate_list"]),
    clusteredProteinsFile = "analysis/core_based/roary/clustered_proteins"
  output:
    core = "analysis/core_based/roary/core_genome.tab"
  resources: mem = config["min_mem"]
  message: "INFO: Generating core genome."
  shell:
    "query_pan_genome -g {input.clusteredProteinsFile} -a intersection -o {output.core} {input.gff3Files}"

rule get_accessory_genome:
  input:
    gff3Files = expand("analysis/core_based/prokka/{isolate}/{isolate}.gff", isolate = config["isolate_list"]),
    clusteredProteinsFile = "analysis/core_based/roary/clustered_proteins"
  output:
    accessory = "analysis/core_based/roary/accessory_genome.tab"
  resources: mem = config["min_mem"]
  message: "INFO: Generating accessory genome."
  shell:
    "query_pan_genome -g {input.clusteredProteinsFile} -a complement -o {output.accessory} {input.gff3Files}"

rule get_core_genome_fasta:
  input:
    clusterFile = "analysis/core_based/roary/clustered_proteins",
    refFastaFile = "analysis/core_based/roary/pan_genome_reference.fa"
  output:
    coreListFile = "analysis/core_based/roary/core_genome.list",
    coreFastaFile = "analysis/core_based/roary/core_genome.fasta"
  params:
    isolateCount = len(config["isolate_list"])
  resources: mem = config["min_mem"]
  message: "INFO: Generating core genome fasta."
  shell:
    "bash MAMBA/scripts/core_genome.bash {input.clusterFile} {params.isolateCount} 1>{output.coreListFile} "
    "&& ruby MAMBA/scripts/fetch_fasta_seqs_for_given_ids.rb \
      --fasta_file {input.refFastaFile} \
      --id_file {output.coreListFile} \
      --reg_exp_to_fetch_id \".+?\s(.+)\" 1>{output.coreFastaFile}"
