#!/usr/bin/env perl
#--------------------------
# @author: Mahesh Vangala
# @email: "<vangalamaheshh@gmail.com>"
# @date: June, 22, 2017
#--------------------------

use strict;
use warnings;
use Getopt::Long;

my $options = parse_options();
print_vcf2fa($$options{'vcffile'}, $$options{'sample'});
exit $?;

sub parse_options {
  my $options = {};
  GetOptions($options, 'sample|s=s', 'vcffile|v=s', 'help|h');
  my $usage = "$0 <--sample|-s> <--vcffile|-v> [--help|h]";
  unless($$options{'sample'} and $$options{'vcffile'}) {
    print STDERR "Usage: $usage\n";
    exit 1;
  }
  return $options;
}

sub print_vcf2fa {
  my($vcf_file, $sample_name) = @_;
  open(FH, "<$vcf_file") or die "Error in opening the file, $vcf_file, $!\n";
  print '>' . $sample_name . "\n";
  while(my $line = <FH>) {
    next if substr($line, 0, 1) eq '#';
    my($chr, $pos, $id, $ref, $alt) = split("\t", $line);
    print $alt eq '.' ? $ref : $alt;
  }
  print "\n";
  close FH or die "Error in clsoing the file, $vcf_file, $!\n";
}
