package PuG::Match;

use strict;
use warnings;

sub new {
  my ( $class, $data ) = @_;
  my $self = {};
  bless $self, $class;

  my $param = $data->{param};
  $self->{_url} = "http://london.randomness.org.uk/wiki.cgi?$param";

  return $self;
}

sub url { return shift->{_url}; }

1;
