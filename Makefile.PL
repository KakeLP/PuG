use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => "PuG",
  VERSION_FROM => "lib/PuG.pm",
  PREREQ_PM    => {
    'Email::Folder'    => 0,
    'Email::MIME'      => 0,
    'HTML::PullParser' => 0,
    'WWW::Mechanize'   => 0,
  },
);
