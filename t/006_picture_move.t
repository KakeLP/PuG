use strict;
use PuG;
use Test::More tests => 7;

my @paras = PuG->extract_info_paras(
                               "t/samples/pug-picture-moved-from-dead-page" );

is( scalar @paras, 1, "extract_info_paras only reports a picture move once" );

my $datum = $paras[0];
isa_ok( $datum, "PuG::Datum" );
is( $datum->type, "picturemove", "...and it is indeed a picturemove" );
is( $datum->url, "http://www.pubsgalore.co.uk/pubs/21993/",
    "...of the correct pub" );
is( $datum->name, "Mabledon Court Hotel", "...correct RGLised name" );
is( $datum->moveurl, "http://www.pubsgalore.co.uk/pubs/21994/",
    "...correct moveurl" );
is( $datum->movename, "Mabel's Tavern", "...correct RGLised movename" );
