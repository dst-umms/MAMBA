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

library(ggplot2)
library(plyr)
library(scales)
library(grid)
library(ggrepel)

options(error = function() traceback(2))

generatePCA <- function(annot, vcf, gds, snp_data_file, pdf_file, ld, threads) {
  snpgdsVCF2GDS(vcf, gds, method = "biallelic.only")
  genofile <- snpgdsOpen(gds)
  set.seed(12345)
  snpset <- snpgdsLDpruning(genofile, ld.threshold = ld, autosome.only = FALSE, remove.monosnp = FALSE, num.thread = threads)
  snpset_ids <- unlist(snpset)
  pca <- snpgdsPCA(genofile, snp.id = snpset_ids, autosome.only = FALSE, remove.monosnp = FALSE,
          need.genmat = TRUE, num.thread = threads)
  dump("snpset", snp_data_file)
  
  df <- data.frame(EV1 = pca$eigenvect[,1], EV2 = pca$eigenvect[,2])
  rownames(df) <- pca$sample.id
  #remove samples with NA values
  df_filtered <- na.omit(df)
  filtered_out_samples <- rownames(which(is.na(df), arr.ind = TRUE))
  print(paste("INFO: Filtered out samples (Due to NaN values in EigenVals): ", 
          paste(filtered_out_samples, collapse = ", "), sep = ""))
  plot_PCAs(annot, df_filtered, pdf_file)
}

plot_PCAs <- function(annot, df, pdf_file) {
  all_plots <- list()
  for (ann in colnames(annot)){
    ann_df <- annot[, ann, drop = F]
    ann_names <- rownames(na.omit(ann_df[, ann, drop = F]))
    df_names <- rownames(df)
    names_to_keep <- intersect(ann_names, df_names)
    g <- ggbiplot(df[names_to_keep, , drop = F], groups = as.character(annot[names_to_keep, ann]), 
          scale = 1, var.scale = 1, obs.scale = 1,
          labels = names_to_keep, choices = 1:2, ellipse=FALSE, circle = FALSE, var.axes = FALSE)
    g <- g + scale_color_discrete(name = ann)
    g <- g + theme(legend.direction = 'horizontal',
                   legend.position = 'top',
                   legend.title = element_text(face="bold"))
    all_plots <- c(all_plots, list(g))
  }

  pdf(pdf_file)
  print(all_plots)
  dev.off()
}

ggbiplot <- function(pcobj, choices = 1:2, scale = 1, pc.biplot = TRUE, 
                      obs.scale = 1 - scale, var.scale = scale, 
                      groups = NULL, ellipse = FALSE, ellipse.prob = 0.68, 
                      labels = NULL, labels.size = 3, alpha = 1, 
                      var.axes = TRUE, 
                      circle = FALSE, circle.prob = 0.69, 
                      varname.size = 3, varname.adjust = 1.5, 
                      varname.abbrev = FALSE, ...) {
  df.u <- pcobj
  df.u$labels <- labels
  df.u$groups <- groups
  names(df.u) <- c('xvar', 'yvar')

  # Base plot
  g <- ggplot(data = df.u, aes(x = xvar, y = yvar)) + 
          xlab("PC1") + ylab("PC2") + coord_equal()

  g <- g + geom_point(aes(xvar, yvar), color = "black", 
                size = 2) + geom_point(aes(color=groups))
  return (g)
}

args <- commandArgs(trailingOnly = TRUE)
VCF_file <- args[1]
meta_file <- args[2]
GDS_file <- args[3]
pca_pdf_file <- args[4]
SNP_data_file <- args[5]
LD_cutoff <- as.numeric(args[6])
num_cores <- as.numeric(args[7])

annot <- read.csv(meta_file, sep = ",", header = T, row.names = 1,
                      stringsAsFactors = FALSE, check.names = F, comment.char = '#')

generatePCA(annot, VCF_file, GDS_file, SNP_data_file, pca_pdf_file, LD_cutoff, num_cores)
