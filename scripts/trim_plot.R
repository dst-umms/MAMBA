#!/usr/bin/env Rscript
#vim: syntax=r tabstop=2 expandtab

library(ggplot2)
library(reshape2)
library(scales)

args <- commandArgs(trailingOnly = TRUE)
data <- read.csv(args[1], header = TRUE, row.names = 1, sep = ",")

x <- data.frame(Sample = rownames(data),
                TotalReads = as.numeric(as.matrix(data[,"TotalReads"])), 
                Surviving = as.numeric(as.matrix(data[,"FilteredReads"])))

x1 <- melt(x, id.var="Sample")

png(args[2], width = 8, height = 8, unit = "in", res = 300)
upper_limit <- max(x$TotalReads)
limits <- seq(0, upper_limit, length.out = 10)

cust_labels <- vector("character",length = length(limits))

if(nchar(upper_limit) < 7) {
  cust_labels <- paste(round(limits/1000), "K", sep = "") 
  limits <- round(limits/1000) * 1000
} else {
  cust_labels <- paste(round(limits/1000000), "M", sep = "") 
  limits <- round(limits/1000000) * 1000000
}


colors <- c(TotalReads="steelblue4", Surviving="steelblue1")

q <- ggplot(x1, aes(x = Sample, y = value, fill = variable)) + geom_bar(stat = "identity", position = "identity") 
q + scale_y_continuous("", limits = c(0, upper_limit), labels = cust_labels, breaks = limits) +
scale_fill_manual(values = colors) + labs(title = "Filtering of Reads based on Quality using Trimmomatic\n\n", x = "Sample Names", y = "") +
guides(fill = guide_legend(title = NULL)) + theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size = 10))

dev.off()

