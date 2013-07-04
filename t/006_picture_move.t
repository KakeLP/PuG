use strict;
use PuG;
use Test::More tests => 7;

my @paras = PuG->extract_info_paras(
                       file => "t/samples/pug-picture-moved-from-dead-page" );

TODO: {
  local $TODO = "Not important yet.";
  is( scalar @paras, 1,
      "extract_info_paras only reports a picture move once" );
};

my $datum = $paras[0];
isa_ok( $datum, "PuG::Datum" );
is( $datum->type, "picturemove", "...and it is indeed a picturemove" );
is( $datum->url, "http://www.pubsgalore.co.uk/pubs/21993/",
    "...of the correct pub" );
is( $datum->name, "Mabeldon Court Hotel", "...correct RGLised name" );
is( $datum->picturemove_new_url, "http://www.pubsgalore.co.uk/pubs/21994/",
    "...correct picturemove_new_url" );
is( $datum->picturemove_new_name, "Mabel's Tavern",
    "...correct RGLised picturemove_new_name" );
