use strict;
use PuG;
use Test::More tests => 1;

my @paras;

eval {
    @paras = PuG->extract_info_paras(
                       file => "t/samples/pug-picture-moved-from-dead-page" );
};
is( $@, "", "extract_info_paras doesn't die on email with no-longer-existing "
    . "pub page" );
