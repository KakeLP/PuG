#!/usr/bin/perl

use strict;
use warnings;

use lib "/Users/kake/working/perl/PuG/lib/";

use PuG;

my $file = $ARGV[0];

if ( $file ) {
  print PuG->print_text_report( file => $ARGV[0] );
} else {
  print "Usage: report.pl <mbox_filename>\n";
}
