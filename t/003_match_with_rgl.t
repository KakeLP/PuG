use strict;
use PuG;
use Test::More tests => 6;

my @paras = PuG->extract_info_paras( file => "t/samples/pug-single-review" );
my $datum = $paras[0];
my @matches = $datum->match_to_rgl;
my $match = $matches[0];
isa_ok( $match, "PuG::Match", "Dog and Fox match" );
is( $match->url,
    "http://london.randomness.org.uk/wiki.cgi?Dog_And_Fox,_SW19_5EA",
    "...matched to correct RGL URL" );

@paras = PuG->extract_info_paras( file => "t/samples/pug-two-single-reviews" );
$datum = $paras[1];
@matches = $datum->match_to_rgl;
$match = $matches[0];
isa_ok( $match, "PuG::Match", "Fox Inn match" );
is( $match->url,
    "http://london.randomness.org.uk/wiki.cgi?Fox_Inn,_BR2_6BQ",
    "...matched to correct RGL URL" );

@paras = PuG->extract_info_paras( file => "t/samples/pug-ec1r" );
$datum = $paras[0];
@matches = $datum->match_to_rgl;
$match = $matches[0];
isa_ok( $match, "PuG::Match", "Gunmakers match" );
is( $match->url,
    "http://london.randomness.org.uk/wiki.cgi?Gunmakers,_EC1R_5ET",
    "...matched to correct RGL URL" );
