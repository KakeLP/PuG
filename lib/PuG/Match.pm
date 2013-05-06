package PuG::Match;

use strict;
use warnings;

=head1 NAME

PuG::Match - Model a single RGL pub, as a match to a Pubs Galore info para.

=head1 DESCRIPTION

Model a single RGL pub, as a match to a Pubs Galore info para.

=head1 METHODS

=over

=item B<new>

  my $match = PuG::Match->new( $pub );

C<$pub> is a reference to a hash of data pulled out of RGL JSON output
for a single pub.

=cut

sub new {
  my ( $class, $data ) = @_;
  my $self = {};
  bless $self, $class;

  my $param = $data->{param};
  $self->{_url} = "http://london.randomness.org.uk/wiki.cgi?$param";

  return $self;
}

=item B<url>

  my $url = $match->url;

An accessor.

=cut

sub url { return shift->{_url}; }

1;
