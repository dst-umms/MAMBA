#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "Apr, 19, 2017"

"""
  Returns the final list of files wanted by the pipeline

  
"""

def getTargetInfo(config):
  targetFiles = []
  targetFiles.extend([
                        _getTrimOut(config),
                        _getSpadesOut(config),
                        _getProkkaOut(config),
                        _getRoaryOut(config),
                        _getCoreAndAccGenomes(config),
                        _getBWAout(config),
                        _getMapStats(config),
                        #_getFilteredSNPs(config),
                        #_getPCA(config),
                        _getRaxml(config),
                        _getGraphlanPlot(config),

                        _getPilonOut(config),
                        _getPilonMergedVcf(config),
                        _getSnp2FaRefBased(config)
                    ])
  return targetFiles

def _getTrimOut(config):
  return ["analysis/trimmomatic/trim_report.png"] 

def _getSpadesOut(config):
  return ["analysis/spades/" + sample + "/contigs.fasta" 
    for sample in config["isolate_list"]]

def _getProkkaOut(config):
  return ["analysis/prokka/" + sample + "/" + sample + ".gbk"
    for sample in config["isolate_list"]]

def _getRoaryOut(config):
  return ["analysis/roary/roary.done"]

def _getCoreAndAccGenomes(config):
  return ["analysis/roary/core_genome.tab", "analysis/roary/accessory_genome.tab"]

def _getBWAout(config):
  return ["analysis/bwa/aln/{sample}/{sample}.sam".format(sample = sample)
    for sample in config["isolate_list"]]

def _getMapStats(config):
  mapOutFiles = ["analysis/bwa/aln/align_report.png"]
  if config["reference"]:
    mapOutFiles.append("analysis/ref_based/bwa/aln/align_report.png")
  return mapOutFiles

def _getFilteredSNPs(config):
  return [["analysis/variants/{sample}/{sample}.indels.filtered.vcf".format(sample = sample),
          "analysis/variants/{sample}/{sample}.snps.filtered.vcf".format(sample = sample)]
            for sample in config["isolate_list"]]

def _getPCA(config):
  return ["analysis/snp2fa/snps.fasta"]

def _getRaxml(config):
  return ["analysis/raxml/RAxML_bestTree.snps"]

def _getGraphlanPlot(config):
  return ["analysis/graphlan/MAMBA.png"]

def _getPilonOut(config):
  return ["analysis/ref_based/pilon/{sample}/{sample}.vcf".format(sample = sample)
    for sample in config["isolate_list"]]


def _getPilonMergedVcf(config):
  return ["analysis/ref_based/pilon/MAMBA.snps.filtered.merged.vcf"]

def _getSnp2FaRefBased(config):
  return ["analysis/ref_based/snp2fa/snps.fasta"]
