package PlugAuth::Client::Tiny;

use strict;
use warnings;
use 5.006;
use HTTP::Tiny;

# ABSTRACT: Minimal PlugAuth client
# VERSION

=head1 SYNOPSIS

 use PlugAuth::Client::Tiny;
 my $client = PlugAuth::Client::Tiny->new( url => "http://localhost:3000/" );
 if($client->auth('primus', 'spark'))
 {
   # authentication succeeded
 }
 else
 {
   # authentication failed
 }

=head1 DESCRIPTION

PlugAuth::Client::Tiny is a minimal L<PlugAuth> client.  It uses L<HTTP::Tiny> 
instead of L<LWP> or L<Mojo::UserAgent>.  It provides only a mechanism for
authenticating and authorizing against a L<PlugAuth> server.  If you need to
modify the users/groups/authorization on the server through the RESTful API
then you will need the heavier L<PlugAuth::Client> which relies on 
L<Clustericious::Client> and L<Mojo::UserAgent>.

=head1 CONSTRUCTOR

The constructor is (predictably) C<new>:

 use PlugAuth::Client::Tiny->new;
 my $client = PlugAuth::Client::Tiny->new;

PlugAuth::Client::Tiny's constructor accepts one optional option:

=over 4

=item url

The URL of the L<PlugAuth> server.  If not specified, C<http://localhost:3000>
is used.

=back

=cut

sub new
{
  ## TODO way to pass arguments to the HTTP::Tiny constructor
  my $class = shift;
  my %args = ref $_[0] ? %{$_[0]} : @_;
  my $url = $args{url} || 'http://localhost:3000/';
  $url =~ s{/?$}{/};
  return bless { 
    url    => $url,
    http   => HTTP::Tiny->new,
  }, $class;
}

=head1 ATTRIBUTES

=head2 $client-E<gt>url

Returns the URL for the L<PlugAuth> server.  This attribute is read-only.

=cut

sub url { shift->{url} }

=head1 METHODS

=head2 $client-E<gt>auth( $user, $password )

Attempt to authenticate against the L<PlugAuth> server using the given username and password.
Returns 1 on success, 0 on failure and dies on a connection failure.

=cut

sub auth
{
  my($self, $user, $password) = @_;
  
  my $response = $self->{http}->get($self->{url} . 'auth', { 
    headers => { 
      ## TODO option for setting the realm
      # WWW-Authenticate: Basic realm="..."
      Authorization => 'Basic ' . do {
        ## TODO maybe use MIME::Base64 if available?
        ## it is XS, but may be faster.
        use integer;
        my $a = join(':', $user,$password);
        my $r = pack('u', $a);
        $r =~ s/^.//mg;
        $r =~ s/\n//g;
        $r =~ tr|` -_|AA-Za-z0-9+/|;
        my $p = (3-length($a)%3)%3;
        $r =~ s/.{$p}$/'=' x $p/e if $p;
        $r;
      },
    } 
  });
  
  return 1 if $response->{status} == 200;
  return 0 if $response->{status} == 403
  ||          $response->{status} == 401;
  
  die $response->{content};
}

=head2 $client-E<gt>authz( $user, $action, $resource)

Determine if the given user is authorized to perform the given action on the given resource.
Returns 1 on success, 0 on failure and dies on connection failure.

=cut

sub authz
{
  my($self, $user, $action, $resource) = @_;
  
  $resource =~ s{^/?}{};
  my $url = $self->{url} . join('/', 'authz', 'user', $user, $action, $resource);
  my $response = $self->{http}->get($url);
  
  return 1 if $response->{status} == 200;
  return 0 if $response->{status} == 403;
  die $response->{content};
}

1;
