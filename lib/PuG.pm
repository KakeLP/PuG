package PuG;

use strict;
use warnings;

use HTML::PullParser;
use PuG::Datum;
use PuG::Email::Folder;
use PuG::Templates;
use Template;

our $VERSION = '0.01';

=head1 NAME

PuG - Parse activity report emails from Pubs Galore, and match up the pubs
mentioned with the corresponding RGL entries.

=head1 DESCRIPTION

Parse activity report emails from Pubs Galore, and match up the pubs
mentioned with the corresponding RGL entries.

=head1 METHODS

=over

=item B<extract_info_paras>

  my @paras = PuG->extract_info_paras( file => $mbox_filename,
                                       verbose => 1 );

Input: the name of an mbox containing Pubs Galore activity reports,
optional verbosity flag.

Returns: an array of L<PuG::Datum> objects, one for each report line.

Note: verbosity defaults to off.  If turned on, it comes as warnings.

=cut

sub extract_info_paras {
  my ( $self, %args ) = @_;
  my $filename = $args{file};
  my $verbose = $args{verbose};
  my @emails = PuG::Email::Folder->new( $filename )->messages;

  my @data;

  foreach my $email ( @emails ) {
    my $body;
    $email->walk_parts( sub {
      my ($part) = @_;
      return if $part->subparts; # multipart
     
      if ( $part->content_type && $part->content_type =~ m[text/html]i ) {
          $body = $part->body;
      }
    } );
    die "No body!" unless $body;

    my $parser = HTML::PullParser->new(
                                        doc   => $body,
                                        start => '"S", tagname, text, attr',
                                        end   => '"E", tagname, text, attr',
                                        text  => '"TEXT", tagname, text, attr',
                                      );

    my ( $in_para, $content );
    while ( my $token = $parser->get_token ) {
      my ( $flag, $tagname, $text, $attr ) = @$token;
      if ( $flag eq "S" && lc( $tagname ) eq "p" && $attr->{class}
           && $attr->{class} eq "information" ) {
        $in_para = 1;
        $content = "";
      } elsif ( $in_para && $flag eq "E" && lc( $tagname ) eq "p" ) {
        $in_para = 0;
        my $datum = PuG::Datum->new( data => $content, verbose => $verbose );
        push @data, $datum;
      } elsif ( $in_para ) {
        $content .= $text;
      }
    }
  }

  return @data;
}

=item B<print_html_report>

  my $report = PuG->print_html_report( file => $mbox_filename,
                                       verbose => 1 );

Input: the name of an mbox containing Pubs Galore activity reports,
optional verbosity flag.

Returns: an HTML report linking the pubs mentioned in the
emails to potentially-corresponding pubs on RGL.

Note: verbosity defaults to off.  If turned on, it comes as warnings.

=cut

sub print_html_report {
  my ( $self, %args ) = @_;

  my @data = PuG->extract_info_paras( file => $args{file},
                                      verbose => $args{verbose} );
  my $template = PuG::Templates->html_report_template;
  my $tt = Template->new;

  @data = sort { $a->name cmp $b->name } @data;
  my @pubs;
  foreach my $datum ( @data ) {
    push @pubs, { puginfo => $datum, rglmatches => [ $datum->match_to_rgl ] };
  }

  my %tt_vars = ( pubs => \@pubs );

  my $report;
  $tt->process( \$template, \%tt_vars, \$report ) || die $tt->error;
  return $report;
}

=item B<print_text_report>

  my $report = PuG->print_text_report( file => $mbox_filename,
                                       verbose => 1 );

Input: the name of an mbox containing Pubs Galore activity reports
optional verbosity flag.

Returns: a formatted text-only report linking the pubs mentioned in the
emails to potentially-corresponding pubs on RGL.

Note: verbosity defaults to off.  If turned on, it comes as warnings.

=cut

sub print_text_report {
  my ( $self, %args ) = @_;

  my @data = PuG->extract_info_paras( file => $args{file},
                                      verbose => $args{verbose} );
  @data = sort { $a->name cmp $b->name } @data;

  my $report;
  foreach my $datum ( @data ) {
    my $name_addr = join ", ", $datum->name, $datum->address || "",
                    $datum->district || "";

    $report .= sprintf( "%s:\n  Event type: %s\n  %s\n", $name_addr,
                        $datum->type, $datum->url );
    my @matches = $datum->match_to_rgl;
    if ( !scalar @matches ) {
      $report .= "No matches!\n\n";
    } else {
      foreach my $match ( @matches ) {
        $report .= sprintf( "  %s\n", $match->url );
      }
      $report .= "\n";
    }
  }

  return $report;
}

=back

=cut

1;
