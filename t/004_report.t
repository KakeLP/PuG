use strict;
use PuG;
use Test::More tests => 7;

# Text report
my $report = PuG->print_text_report( file => "t/samples/pug-single-review" );
ok( $report, "->print_text_report returns something" );
like( $report, qr/Dog And Fox, 24 High Street Wimbledon, SW19/,
      "...mentions Dog and Fox" );
like( $report,
      qr'http://london.randomness.org.uk/wiki.cgi\?Dog_And_Fox,_SW19_5EA',
      "...and relevant RGL URL" );

# HTML report
$report = PuG->print_html_report( file => "t/samples/pug-single-review" );
ok( $report, "->print_html_report returns something" );
like( $report, qr'<html>', "...claims to be HTML" );
like( $report, qr/Dog\s+And\s+Fox,\s+24\s+High\s+Street\s+Wimbledon,\s+SW19/,
      "...mentions Dog and Fox" );
like( $report,
      qr'http://london.randomness.org.uk/wiki.cgi\?Dog_And_Fox,_SW19_5EA',
      "...and relevant RGL URL" );
