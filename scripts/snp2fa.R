#!/usr/bin/env Rscript
#vim: syntax=r tabstop=2 expandtab

#------------------------------------
#@author: Mahesh Vangala
#@email: "<vangalamaheshh@gmail.com>"
#@date: June, 8, 2017
#-------------------------------------

library(gdsfmt)

options(error = function() traceback(2))

gds2fasta <- function (gdsobj, file.name, id_file.name, snp.id = NULL, verbose = FALSE) {
  stopifnot(class(gdsobj) == "gds.class")

  if (verbose)
    cat("Extract SNP data as FASTA format from GDS:\n")
  total.snp.ids <- read.gdsn(index.gdsn(gdsobj, "snp.id"))
  snp.ids <- total.snp.ids
  
  if (!is.null(snp.id)) {
    n.tmp <- length(snp.id)
    snp.id <- snp.ids %in% snp.id
    n.snp <- sum(snp.id)
    if (n.snp != n.tmp)
      stop("Some of snp.id do not exist!")
    if (n.snp <= 0)
      stop("No SNP in the working dataset.")
    snp.ids <- snp.ids[snp.id]
  }
    
  snp.idx <- match(snp.ids, total.snp.ids)

  rep.genotype <- read.gdsn(index.gdsn(gdsobj, "genotype"))[,snp.idx]
  rep.allele <- do.call(rbind, strsplit(read.gdsn(index.gdsn(gdsobj, "snp.allele"))[snp.idx], "/", fixed = TRUE))
  sample.id <- read.gdsn(index.gdsn(gdsobj, "sample.id"))

  cat(paste(read.gdsn(index.gdsn(gdsobj, "snp.rs.id"))[snp.idx], collapse = "\n"), "\n", file = id_file.name)

  seq.len <- length(snp.idx)
  cat("", file = file.name) # Make a new empty file

  for (i in 1:length(sample.id)) {
    seq <- character(seq.len)
    for (j in 1:seq.len) {
      if (rep.genotype[i,j] == 0) {
        seq[j] <- rep.allele[j,2]
      } else if (rep.genotype[i,j] == 2) {
        seq[j] <- rep.allele[j,1]
      } else if (rep.genotype[i,j] == 1) {
        if ((rep.allele[j,1] == "A" && rep.allele[j,2] == "G") || (rep.allele[j,1] == "G" && rep.allele[j,2] == "A")) {
          seq[j] <- "R"
        } else if ((rep.allele[j,1] == "A" && rep.allele[j,2] == "C") || (rep.allele[j,1] == "C" && rep.allele[j,2] == "A")) {
          seq[j] <- "M"
        } else if ((rep.allele[j,1] == "A" && rep.allele[j,2] == "T") || (rep.allele[j,1] == "T" && rep.allele[j,2] == "A")) {
          seq[j] <- "W"
        } else if ((rep.allele[j,1] == "C" && rep.allele[j,2] == "T") || (rep.allele[j,1] == "T" && rep.allele[j,2] == "C")) {
          seq[j] <- "Y"
        } else if ((rep.allele[j,1] == "C" && rep.allele[j,2] == "G") || (rep.allele[j,1] == "G" && rep.allele[j,2] == "C")) {
          seq[j] <- "S"
        } else if ((rep.allele[j,1] == "G" && rep.allele[j,2] == "T") || (rep.allele[j,1] == "T" && rep.allele[j,2] == "G")) {
          seq[j] <- "K"
        } else {
          seq[j] <- "N"
        }
      } else {
        seq[j] <- "N"
      }
    }
    cat(">", sample.id[i], "\n", file = file.name, sep = "", append = TRUE)
    cat(seq, "\n", file = file.name, sep = "", append = TRUE)
  }

  return(invisible(NULL))
}

args <- commandArgs( trailingOnly = TRUE )
gdsFile <- args[1]
snpDataFile <- args[2]
fastaFile <- args[3]
idFile <- args[4]

genofile <- openfn.gds(gdsFile)
snpset <- load(snpDataFile)
snpset_ids <- unlist(snpset)
gds2fasta(genofile, fastaFile, idFile, snp.id = snpset_ids)
