package PuG::Templates;

use strict;
use warnings;

sub html_report_template {
  return <<EOF;
<html>
<head><title>PuG Report</title></head>
<body>
  <h1>PuG Report</h1>

  <ul>
    [% FOREACH pub = pubs %]
      <li>[% pub.puginfo.name %], [% pub.puginfo.address %],
          [% pub.puginfo.district %]:
          <ul>
            <li>Event type: [% pub.puginfo.type %]</li>
            <li><a href="[% pub.puginfo.url %]">[% pub.puginfo.url %]</a></li>
            [% FOREACH match = pub.rglmatches %]
              <li><a href="[% match.url %]">[% match.url %]</a></li>
            [% END %]
          </ul>
      </li>
    [% END %]
  </ul>

</body>
</html>
EOF
}

1;
