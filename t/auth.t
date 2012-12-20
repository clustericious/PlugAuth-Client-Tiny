use strict;
use warnings;
use v5.10;
use Test::More tests => 4;

eval q{
  use PlugAuth::Client::Tiny;
};

my $last_url;

my $client = PlugAuth::Client::Tiny->new;

ok eval { $client->auth('primus', 'spark') }, 'auth ok primus:spark';
diag $@ if $@;

is $last_url, 'http://localhost:3000/auth', 'url = http://localhost:3000/auth';
undef $last_url;

ok eval { !$client->auth('bogus', 'bogus') }, 'auth not ok bogus:bogus';
diag $@ if $@;

is $last_url, 'http://localhost:3000/auth', 'url = http://localhost:3000/auth';

package HTTP::Tiny;

use MIME::Base64 qw( decode_base64 );
BEGIN { $INC{'HTTP/Tiny.pm'} = __PACKAGE__ };

sub new { bless {}, 'HTTP::Tiny' }

sub get 
{
  my($self, $url, $options) = @_;
  $last_url = $url;
  if($options->{headers}->{Authorization} =~ /^Basic (.*)$/)
  {
    my($user,$pass) = split /:/, decode_base64($1);
    if($user eq 'primus' && $pass eq 'spark')
    {
      return { status => 200 };
    }
    else
    {
      return { status => 403 };
    }
  }
  else
  {
    return { status => 401 };
  }
}