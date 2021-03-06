#!/usr/bin/perl

use strict;
use warnings;

use lib "/Users/kake/working/perl/PuG/lib/";

use Getopt::Mini;
use PuG;

my $file = $ARGV{""};
# Default to plain-text reports.
my $format = $ARGV{"format"} || "text";

if ( !$file || ref $file
     || ( $format ne "text" && $format ne "html" )
     || exists $ARGV{"h"} ) {
  print "Usage: $0 [-v] [--format 'text'|'html'] mbox_filename\n"
      . "       $0 -h\n"
      . "Note: -v gives you verbosity, emitted as warnings\n";
  exit 0;
}

if ( ! -e $file ) {
  print "$file not found.\n";
  exit 0;
}

if ( ! -r $file ) {
  print "$file not readable.\n";
  exit 0;
}

my $verbose = ( exists $ARGV{"v"} ? 1 : 0 );
if ( $format eq "html" ) {
  print PuG->print_html_report( file => $file, verbose => $verbose );
} else {
  print PuG->print_text_report( file => $file, verbose => $verbose );
}
