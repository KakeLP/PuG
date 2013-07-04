use strict;
use PuG;
use Test::More tests => 38;

# mbox with a single message including one review
my @paras;
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  @paras = PuG->extract_info_paras( file => "t/samples/pug-single-review" );
};
is( $@, "", "->extract_info_paras doesn't warn by default" );
eval {
  local $SIG{__WARN__} = sub { die $_[0] };
  @paras = PuG->extract_info_paras( file => "t/samples/pug-single-review",
                                    verbose => 1 );
};
ok( $@, "...but it does when you ask for verbosity" );
like( $@, qr/\bDog\b.*\bFox/, "...and the warning seems to mention the pub" );
is( scalar @paras, 1, "single info para found in one mail" );
my $datum = $paras[0];
isa_ok( $datum, "PuG::Datum" );
is( $datum->type, "review", "...and it's a review" );
is( $datum->url, "http://www.pubsgalore.co.uk/pubs/24672/",
    "...of the correct pub" );
is( $datum->name, "Dog And Fox", "...correct RGLised name" );
is( $datum->address, "24 High Street Wimbledon", "...correct address" );
is( $datum->district, "SW19", "...correct postal district" );

# mbox with two messages, each including one review
@paras = PuG->extract_info_paras( file => "t/samples/pug-two-single-reviews" );
is( scalar @paras, 2, "two info paras found in two mails" );
isa_ok( $paras[0], "PuG::Datum", "first one" );
is( $paras[0]->type, "review", "...correct type" );
is( $paras[0]->name, "Dog And Fox", "...correct RGLised name" );
is( $paras[0]->address, "24 High Street Wimbledon", "...correct address" );
is( $paras[0]->district, "SW19", "...correct postal district" );
isa_ok( $paras[1], "PuG::Datum", "second one" );
is( $paras[1]->type, "review", "...correct type" );
is( $paras[1]->name, "Fox Inn And Restaurant", "...correct RGLised name" );
is( $paras[1]->address, "Heathfield Road", "...correct address" );
is( $paras[1]->district, "BR2", "...correct postal district" );

# mbox with single message containing two picture notifications and one open
@paras = PuG->extract_info_paras( file => "t/samples/pug-pictures-and-open" );
is( scalar @paras, 3, "three info paras found in one mail" );
isa_ok( $paras[0], "PuG::Datum", "first one" );
is( $paras[0]->type, "picture", "...correct type" );
is( $paras[0]->name, "Mojama", "...correct RGLised name" );
is( $paras[0]->address, "36 High Street", "...correct address" );
is( $paras[0]->district, "CR0", "...correct postal district" );
isa_ok( $paras[1], "PuG::Datum", "second one" );
is( $paras[1]->type, "open", "...correct type" );
is( $paras[1]->name, "Mojama", "...correct RGLised name" );
is( $paras[1]->address, "36 High Street", "...correct address" );
is( $paras[1]->district, "CR0", "...correct postal district" );
isa_ok( $paras[2], "PuG::Datum", "third one" );
is( $paras[2]->type, "picture", "...correct type" );
is( $paras[2]->name, "Fox Inn", "...correct RGLised name" );
is( $paras[2]->address, "Heathfield Road", "...correct address" );
is( $paras[2]->district, "BR2", "...correct postal district" );

# pub in EC1 district (postcode starts EC1R)
@paras = PuG->extract_info_paras( file => "t/samples/pug-ec1r" );
is( $paras[0]->district, "EC1", "correct postal district for EC1R pub" );
