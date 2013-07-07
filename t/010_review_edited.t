use strict;
use PuG;
use Test::More tests => 2;

# edit made to existing review
my @paras = PuG->extract_info_paras( file => "t/samples/pug-review-edited" );
is( $paras[0]->type, "review-edited", "correct type for review-edited" );
is( $paras[0]->name, "Hundred Crows Rising", "...correct RGLised name" );
