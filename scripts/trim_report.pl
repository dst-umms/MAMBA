#!/usr/bin/env perl
#vim: syntax=perl tabstop=2 expandtab

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $options = parse_options();
my $trim_info = get_trim_info($$options{'trim_log_file'});
print_trim_info($trim_info);
exit $?;

sub parse_options {
  my $options = {};
  GetOptions($options, 'trim_log_file|l=s@', 'help|h');
  unless($$options{'trim_log_file'}) {
    print STDERR "Usage: $0 <--trim_log_file|-l> [--trim_log_file|-l]\n";
    exit 1;
  }
  return $options;
}

sub get_trim_info {
  my $trim_info = {};
  my($file_list) = @_;
  foreach my $trim_file(@$file_list) {
    my($sample) = basename(dirname($trim_file));
    open(FH, "<$trim_file") or die "Error in opening the file, $trim_file, $!\n";
    while(my $line = <FH>) {
      chomp $line;
      if($line =~ /^Input Read Pairs:/) {
        my($total_reads, $filtered_reads) = ($line =~ /.+?\s(\d+)\s.+?\s(\d+)/);
        $$trim_info{$sample} = [$total_reads, $filtered_reads];
      }
    }
    close FH or die "Error in closing the file, $trim_file, $!\n";
  }
  return $trim_info;
}

sub print_trim_info {
  my($trim_info) = @_;
  print STDOUT join(",", qw(SampleName TotalReads FilteredReads)), "\n";
  foreach my $sample(keys %$trim_info) {
    print STDOUT join(",", ($sample, @{$$trim_info{$sample}})), "\n";              
  }
}
