package PuG::Datum;

use strict;
use warnings;

use HTML::PullParser;
use JSON;
use PuG::Match;
use WWW::Mechanize;

=head1 NAME

PuG::Datum - Model a single info paragraph from a Pubs Galore activity report email.

=head1 DESCRIPTION

Model a single info paragraph from a Pubs Galore activity report email.

=head1 METHODS

=over

=item B<new>

  my $content = qq( A review has been submitted for <a
    href="http://www.pubsgalore.co.uk/pubs/24672/">Dog &amp; Fox</a> in SW19,
    London (Greater) by <a
    href="http://www.pubsgalore.co.uk/userinfo.php?name=John+Grenade">Doug
    Middleton</a>. );
  my $datum = PuG::Datum->new( $content );

Input: A single info paragraph (HTML) from a Pubs Galore activity report.

=cut

sub new {
  my ( $class, $data ) = @_;
  my $self = {};
  bless $self, $class;

  # Store things we can get directly from the supplied data.
  $self->{_name} = $self->_identify_name( $data );
  $self->{_type} = $self->_identify_type( $data );
  $self->{_url} = $self->_identify_url( $data );
  if ( $self->type eq "picturemove" ) {
    $self->{_picturemove_new_name}
      = $self->_identify_picturemove_new_name( $data );
    $self->{_picturemove_new_url}
      = $self->_identify_picturemove_new_url( $data );
  }

  # Now go and get things from the PuG site.
  $self->{_address} = $self->_identify_address( $data );
  $self->{_district} = $self->_identify_district( $data );

  return $self;
}

=item B<match_to_rgl>

  my @matches = $datum->match_to_rgl;

Returns false if necessary data not found.  Otherwise returns an array
of L<PuG::Match> objects; this will be empty if no potential matches
were found.  There may be more than one potential match.

=cut

sub match_to_rgl {
  my $self = shift;

  # Can't do any matching if we've not got our data yet.
  my $district = $self->district;
  my $name = $self->name;
  return unless $district && $name;

  # Check the pubs in this postal district.
  my $url = "http://london.randomness.org.uk/wiki.cgi?action=index&"
            . "format=json&cat=pubs&loc=" . lc( $district );
  my $mech = WWW::Mechanize->new();
  $mech->get( $url );
  my $content = $mech->content();
  die $mech->status unless $mech->success;
  my $data = decode_json $content;
  my @pubs = @$data;

  # Check everything in Now Closed.
  $url = "http://london.randomness.org.uk/wiki.cgi?action=index&"
            . "format=json&cat=now+closed";
  $mech->get( $url );
  $content = $mech->content();
  $data = from_json $content;
  push @pubs, @$data;

  my @matches;
  foreach my $pub ( @pubs ) {
    my $rgl_name = $pub->{name};
    my $rgl_pc = $pub->{node_data}{metadata}{postcode}[0];
    my $rgl_name_no_pc = $rgl_name;
    $rgl_name_no_pc =~ s/, $rgl_pc//;
    if ( ( $rgl_name =~ m/$name/ || $name =~ m/$rgl_name_no_pc/ )
         && $rgl_name =~ m/$district/ ) {
      my $match = PuG::Match->new( $pub );
      push @matches, $match;
    }
  }

  return @matches;
}

=item B<pub_page_html>

  my $html = $datum->pub_page_html;

Returns the HTML source of the pub page this datum is about.  Dies if
the datum can't identify the pub page URL.  Caches the HTML after the
first request.

=cut

sub pub_page_html {
  my $self = shift;
  return $self->{_pub_page_html} if $self->{_pub_page_html};
  my $url = $self->url || die "No URL for " . $self->name . "!\n";
  my $mech = WWW::Mechanize->new( quiet => 1, autocheck => 0 );
  $mech->get( $url );
  if ( $mech->success() ) {
    my $content = $mech->content();
    $self->{_pub_page_html} = $content;
  }
}

# Internal methods to pull out data.

sub _identify_address {
  my ( $self, $data ) = @_;
  my $html = $self->pub_page_html;
  return unless $html;

  my $parser = HTML::PullParser->new(
                                      doc   => $html,
                                      start => '"S", tagname, text, attr',
                                      end   => '"E", tagname, text, attr',
                                      text  => '"TEXT", tagname, text, attr',
                                    );

  my $address;
  my ( $in_span, $content );
  while ( my $token = $parser->get_token ) {
    my ( $flag, $tagname, $text, $attr ) = @$token;
    if ( $flag eq "S" && lc( $tagname ) eq "span" && $attr->{class}
         && $attr->{class} eq "address" ) {
      $in_span = 1;
    } elsif ( $in_span && $flag eq "E" && lc( $tagname ) eq "span" ) {
      last;
    } elsif ( $in_span ) {
      $address .= $text;
    }
  }

  $address =~ s/\s+/ /;
  return $address;
}

sub _identify_district {
  my ( $self, $data ) = @_;
  my $html = $self->pub_page_html;
  return unless $html;

  my $parser = HTML::PullParser->new(
                                      doc   => $html,
                                      start => '"S", tagname, text, attr',
                                      end   => '"E", tagname, text, attr',
                                      text  => '"TEXT", tagname, text, attr',
                                    );

  my $district;
  my ( $in_span, $content );
  while ( my $token = $parser->get_token ) {
    my ( $flag, $tagname, $text, $attr ) = @$token;
    if ( $flag eq "S" && lc( $tagname ) eq "span" && $attr->{class}
         && $attr->{class} eq "postcode" ) {
      $in_span = 1;
    } elsif ( $in_span && $flag eq "E" && lc( $tagname ) eq "span" ) {
      last;
    } elsif ( $in_span ) {
      $district .= $text;
    }
  }

  $district =~ s/\s.*$//;
  return $district;
}

sub _identify_name {
  my ( $self, $data ) = @_;
  $data =~ m|<a href="http://www.pubsgalore.co.uk/pubs/\d+/">([^<]+)</a>|;
  return $self->_rglise( $1 );
}

sub _identify_picturemove_new_name {
  my ( $self, $data ) = @_;
  $data =~ m|has been moved to <a href="http://www.pubsgalore.co.uk/pubs/\d+/">([^<]+)<|;
  return $self->_rglise( $1 );
}

sub _identify_picturemove_new_url {
  my ( $self, $data ) = @_;
  $data =~ m|has been moved to <a href="(http://www.pubsgalore.co.uk/pubs/\d+/)">|;
  return $1;
}

sub _identify_type {
  my ( $self, $data ) = @_;
  if ( $data =~ m/^A review has been submitted for/ ) {
    return "review";
  } elsif ( $data =~ m/^\d+ pictures have been added/
            || $data =~ m/^A picture has been added/ ) {
    return "picture";
  } elsif ( $data =~ m/^A picture for.*has been moved to/ ) {
    return "picturemove";
  } elsif ( $data =~ m/^A request to mark.*as open/ ) {
    return "open";
  }
}

sub _identify_url {
  my ( $self, $data ) = @_;
  $data =~ m|<a href="(http://www.pubsgalore.co.uk/pubs/\d+/)">|;
  return $1;
}

sub _rglise {
  my ( $self, $name ) = @_;
  $name =~ s/\s+/ /g;
  $name =~ s/&amp;/And/g;
  $name =~ s/^The //;
  $name =~ s/&#039;/'/g;
  return $name;
}

=item B<accessors>

Accessors: address, district (i.e. postal district, e.g. SW15), name,
type, url.

Type can be: open, picture, picturemove, review.

When type is picturemove, we also have accessors picturemove_new_name and
picturemove_new_url.

=cut

sub address { return shift->{_address}; }
sub district { return shift->{_district}; }
sub name { return shift->{_name}; }
sub picturemove_new_name { return shift->{_picturemove_new_name}; }
sub picturemove_new_url { return shift->{_picturemove_new_url}; }
sub type { return shift->{_type}; }
sub url { return shift->{_url}; }

1;
