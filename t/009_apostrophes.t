use strict;
use PuG;
use Test::More tests => 3;

my $file = "t/samples/pug-queens-head";

my @data = PuG->extract_info_paras( file => $file );
is( scalar @data, 1, "single info para found in Queens Head mail" );
my $datum = $data[0];
isa_ok( $datum, "PuG::Datum" );
my @matches = $datum->match_to_rgl;
ok( scalar @matches, "...found an RGL match for it" );
