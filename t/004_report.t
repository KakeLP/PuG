use strict;
use PuG;
use Test::More tests => 11;

my $file = "t/samples/pug-single-review";

# Text report
my $report = PuG->print_text_report( file => $file );
ok( $report, "->print_text_report returns something" );
run_more_tests( $report);

# HTML report
$report = PuG->print_html_report( file => $file );
ok( $report, "->print_html_report returns something" );
like( $report, qr'<html>', "...claims to be HTML" );
run_more_tests( $report);

sub run_more_tests {
  my $report = shift;
  like( $report, qr/Dog\s+And\s+Fox,\s+24\s+High\s+Street\s+Wimbledon,\s+SW19/,
        "...mentions Dog and Fox" );
  like( $report,
        qr'http://london.randomness.org.uk/wiki.cgi\?Dog_And_Fox,_SW19_5EA',
        "...and relevant RGL URL" );
  like( $report,
        qr'http://www.pubsgalore.co.uk/pubs/24672/',
        "...and relevant PuG URL" );
   like( $report, qr'Event type: review', "...and correct event type" );
}
