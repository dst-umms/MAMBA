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
    gff3Files = expand("analysis/prokka/{isolate}/{isolate}.gff", isolate = config["isolates"].keys())
  output:
    "analysis/roary/roary.done"
  threads: 12
  shell:
    "roary -p {threads} -f analysis/roary -e -n -r {input.gff3Files} "
    "&& touch {output}"
