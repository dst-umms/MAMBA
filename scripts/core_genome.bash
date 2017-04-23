#!/usr/bin/env bash

set -euo pipefail

clusterFile="$1"
isolateCount="$2"

cat $clusterFile | perl -e \
  'my($isolateCount) = @ARGV[0];
  while(my $line = <STDIN>) { 
    chomp $line; 
    my($id, @info) = split("\t", $line); 
    my $first = undef; 
    ($id, $first) = ($id =~ /(.+?)\:\s+(.+)/); 
    push @info, $first; 
    if((scalar @info / $isolateCount) * 100 >= 95) { 
      print $id, "\n"; 
    }
  }' $isolateCount

#make sure ruby bio gem is installed
#if not install it 
gemFound=$(gem list | grep bio)
if [ -z "$gemFound" ]; then
  echo "gem 'bio' not found, installing ...."
  gem install bio
  echo "Done!"
fi
exit $?
