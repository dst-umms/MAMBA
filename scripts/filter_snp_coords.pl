#!/usr/bin/env perl
#------------------------
# @author: Mahesh Vangala
# @date: June, 22, 2017
# @email: "<vangalamaheshh@gmail.com>"
#------------------------

use strict;
use warnings;
use Getopt::Long;

my $options = parse_options();
my $coord_info = get_coord_info($$options{'coordfile'});
print_coords($coord_info, $$options{'vcffile'});
exit $?;

sub parse_options {
  my $options = {};
  GetOptions($options, 'coordfile|c=s', 'vcffile|v=s', 'help|h');
  my $usage = "$0 --coordfile|-c --vcffile|-v [--help|-h]";
  unless($$options{'coordfile'} and $$options{'vcffile'}) {
    print STDERR "Usage: $usage\n";
    exit 1;
  }
  return $options;
}

sub get_coord_info {
  my($file) = @_;
  my $info = {};
  open(FH, "<$file") or die "error in opening the file, $file, $!\n";
  while(my $line = <FH>) {
    chomp $line;
    $$info{$line} = undef;
  }
  close FH or die "Error in closing the file, $file, $!\n";
  return $info;
}

sub print_coords {
  my($info, $file) = @_;
  open(FH, "<$file") or die "Error in opening the file, $file, $!\n";
  while(my $line = <FH>) {
    next if substr($line, 0, 1) eq '#';
    my($chr, $pos, $id, $ref, $alt, $qual, $filter, $feature_info) = split("\t", $line);
    if(exists $$info{$pos} and $filter eq 'PASS' and length($ref) == 1 and
          length($alt) == 1) {
      my($depth) = ($feature_info =~ /DP=(\d+)/);
      $depth > 9 ? print $pos, "\n" : next;     
    }    
  }
  close FH or die "Error in closing the file, $file, $!\n";
}
