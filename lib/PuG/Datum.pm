package PuG::Datum;

use strict;
use warnings;

use HTML::PullParser;
use JSON;
use PuG::Match;
use WWW::Mechanize;

sub new {
  my ( $class, $data ) = @_;
  my $self = {};
  bless $self, $class;

  # Store things we can get directly from the supplied data.
  $self->{_name} = $self->identify_name( $data );
  $self->{_type} = $self->identify_type( $data );
  $self->{_url} = $self->identify_url( $data );

  # Now go and get things from the PuG site.
  $self->{_address} = $self->identify_address( $data );
  $self->{_district} = $self->identify_district( $data );

  return $self;
}

# my @matches = $datum->match_to_rgl;

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

sub pub_page_html {
  my $self = shift;
  return $self->{_pub_page_html} if $self->{_pub_page_html};
  my $url = $self->url || die "No URL for " . $self->name . "!\n";
  my $mech = WWW::Mechanize->new();
  $mech->get( $url );
  my $content = $mech->content();
  $self->{_pub_page_html} = $content;
}

sub identify_address {
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

sub identify_district {
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

sub identify_name {
  my ( $self, $data ) = @_;
  $data =~ m|<a href="http://www.pubsgalore.co.uk/pubs/\d+/">([^<]+)</a>|;
  my $name = $1;
  $name =~ s/\s+/ /g;
  $name =~ s/&amp;/And/g;
  $name =~ s/^The //;
  return $name;
}

sub identify_type {
  my ( $self, $data ) = @_;
  if ( $data =~ m/^A review has been submitted for/ ) {
    return "review";
  } elsif ( $data =~ m/^\d+ pictures have been added/
            || $data =~ m/^A picture has been added/ ) {
    return "picture";
  } elsif ( $data =~ m/^A request to mark.*as open/ ) {
    return "open";
  }
}

sub identify_url {
  my ( $self, $data ) = @_;
  $data =~ m|<a href="(http://www.pubsgalore.co.uk/pubs/\d+/)">|;
  return $1;
}

sub address { return shift->{_address}; }
sub district { return shift->{_district}; }
sub name { return shift->{_name}; }
sub type { return shift->{_type}; }
sub url { return shift->{_url}; }

1;
