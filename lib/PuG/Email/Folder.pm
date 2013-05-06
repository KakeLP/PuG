package PuG::Email::Folder;
use base 'Email::Folder';

use Email::MIME;

sub bless_message {
    my $self    = shift;
    my $message = shift || die "You must pass a message\n";
    return Email::MIME->new( $message );
}

1;