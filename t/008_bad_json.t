use strict;
use PuG;
use Test::More tests => 2;

# mbox including info on a pub in EC3 (this locale includes Simpson's Tavern,
# which has an address with a 1/2 in it)
my $file = "t/samples/pug-ec3";

my @data = PuG->extract_info_paras( file => $file );
my %all_matches;
eval {
  foreach my $datum ( @data ) {
    my @matches = $datum->match_to_rgl;
    foreach my $match ( @matches ) {
      $all_matches{$match->url} = 1;
    }
  }
};
is( $@, "", "->match_to_rgl doesn't die on dataset including EC3 pub" );
ok( $all_matches{"http://london.randomness.org.uk/wiki.cgi?Crosse_Keys,_EC3V_0DR"},
    "...and we got a match for it" );
