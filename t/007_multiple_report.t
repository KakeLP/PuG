use strict;
use PuG;
use Test::More tests => 8;

my $file = "t/samples/pug-multiple-emails";

# Text report
my $report = eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  PuG->print_text_report( file => $file );
};
is( $@, "", "no warnings from ->print_text_report" );
like( $report, qr/Alma, 78 Chapel Market, N1:\s+Event type: locale/,
      "...correct 'locale' event for Alma" );
like( $report, qr/La Tasca, 38-40 High Street,\s+CR0:\s+Event type: closed/,
      "...correct 'closed' event for La Tasca" );
run_more_tests( $report);

# HTML report
$report = eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  PuG->print_html_report( file => $file );
};
is( $@, "", "no warnings from ->print_html_report" );
like( $report,
      qr/Alma, 78 Chapel Market,\s+N1:\s+<ul>\s+<li>Event type: locale/,
      "...correct 'locale' event for Alma" );
like( $report,
      qr/La Tasca, 38-40 High Street,\s+CR0:\s+<ul>\s+<li>Event type: closed/,
      "...correct 'closed' event for La Tasca" );
run_more_tests( $report);

sub run_more_tests {
  my $report = shift;
  like( $report, qr/Alexandra.*Angel.*Bar\s+Latina/s,
        "...seems to be in alphabetical order" );
}
