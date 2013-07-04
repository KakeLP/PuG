use strict;
use PuG;
use Test::More tests => 18;

my $file = "t/samples/pug-single-review";

# Text report
my $report;
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  $report = PuG->print_text_report( file => $file );
};
ok( $report, "->print_text_report returns something" );
is( $@, "", "...and doesn't warn by default" );
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  $report = PuG->print_text_report( file => $file, verbose => 1 );
};
ok( $@, "...but it does when you ask for verbosity" );
like( $@, qr/\bDog\b.*\bFox/, "...and the warning seems to mention the pub" );
unlike( $report, qr'<html>', "the report doesn't claim to be HTML" );
run_more_tests( $report);

# HTML report
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  $report = PuG->print_html_report( file => $file );
};
ok( $report, "->print_html_report returns something" );
is( $@, "", "...and doesn't warn by default" );
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  $report = PuG->print_html_report( file => $file, verbose => 1 );
};
ok( $@, "...but it does when you ask for verbosity" );
like( $@, qr/\bDog\b.*\bFox/, "...and the warning seems to mention the pub" );
like( $report, qr'<html>', "the report claims to be HTML" );
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
