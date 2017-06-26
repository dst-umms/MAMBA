#!/usr/bin/env perl
#----------------------
# @author: Mahesh Vangala
# @email: "<vangalamaheshh@gmail.com>"
# @date: June, 22, 2017
#-----------------------

use strict;
use warnings;
use Getopt::Long;

my $options = parse_options();
my $coord_info = get_coord_info($$options{'coordfile'});
print_vcf($coord_info, $$options{'vcffile'});
exit $?;

sub parse_options {
  my $options = {};
  GetOptions($options, 'vcffile|v=s', 'coordfile|c=s', 'help|h');
  my $usage = "$0 <--vcffile|-v> <--coordfile|-c> [--help|-h]";
  unless($$options{'vcffile'} and $$options{'coordfile'}) {
    print STDERR "Usage: $usage\n";
    exit 1;
  }
  return $options;
}

sub get_coord_info {
  my($file) = @_;
  my $info = {};
  open(FH, "<$file") or die "Error in opening the file, $file, $!\n";
  while(my $line = <FH>) {
    chomp $line;
    my($chr, $pos) = split(",", $line);
    $$info{$chr}{$pos} = undef;
  }
  close FH or die "Error in closing the file, $file, $!\n";
  return $info;
}

sub print_vcf {
  my($info, $file) = @_;
  open(FH, "<$file") or die "Error in opening the file, $file, $!\n";
  while(my $line = <FH>) {
    if(substr($line, 0, 1) eq '#') {
      print $line;
      next;
    }
    my($chr, $pos) = split("\t", $line);
    print $line if exists $$info{$chr}{$pos};
  }
  close FH or die "Error in closing the file, $file, $!\n";
}
