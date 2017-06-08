#!/usr/bin/env Rscript
#vim: syntax=r tabstop=2 expandtab
#-------------------
# @author: Mahesh Vangala
# @email: "<vangalamaheshh@gmail.com>"
# @date: June, 7, 2017 
#--------------------

if(all(is.element(c("gdsfmt", "SNPRelate"), installed.packages()))){
  library(gdsfmt)
  library(SNPRelate)
} else {
  require("devtools")
  install_github("zhengxwen/gdsfmt")
  install_github("zhengxwen/SNPRelate")
  require(gdsfmt)
  require(SNPRelate)
}

options(error = function() traceback(2))

generatePCA <- function(vcf, gds, snp_data_file, ld, threads) {
  snpgdsVCF2GDS(vcf, gds, method = "biallelic.only")
  genofile <- openfn.gds(gds)
  set.seed(12345)
  snpset <- snpgdsLDpruning(genofile, ld.threshold = ld)
  snpset_ids <- unlist(snpset)
  pca <- snpgdsPCA(genofile, snp.id = snpset_ids, num.thread = threads)
  dump("pca", "/project/umw_paul_langlois/dst/devel/umv/projects/saureus/doyle/pca.Rdmpd")
  dump("snpset", snp_data_file)
}

args <- commandArgs(trailingOnly = TRUE)
VCF_file <- args[1]
GDS_file <- args[2]
SNP_data_file <- args[3]
LD_cutoff <- args[4]
num_cores <- args[5]

generatePCA(VCF_file, GDS_file, SNP_data_file, LD_cutoff, num_cores)
