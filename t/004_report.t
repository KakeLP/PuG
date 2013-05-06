use strict;
use PuG;
use Test::More tests => 1;

my $report = PuG->print_text_report( file => "t/samples/pug-single-review" );
ok( $report, "->print_text_report returns something" );
print $report;
