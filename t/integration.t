use strict;
use warnings;
use Test::More;
use PlugAuth::Client::Tiny;

BEGIN {
  plan skip_all => 'Test requires Devel::Hide, Clustericious 1.06; Test::Clustericious::Cluster 0.25, PlugAuth 0.32 and forks'
    unless eval q{
      use Clustericious 1.06;
      use Devel::Hide qw( EV );
      use Test::Clustericious::Cluster 0.25;
      use PlugAuth 0.32;
      use forks;
      1
   };
}

plan tests => 2;

my $cluster = Test::Clustericious::Cluster->new;
$cluster = $cluster->create_cluster_ok('PlugAuth');

my $client = PlugAuth::Client::Tiny->new(
  url => $cluster->url
);

sub dothread (&)
{
  my $thread = threads->create($_[0]);
  Mojo::IOLoop->one_tick while $thread->is_running;
  $thread->join;
}

is dothread { $client->version }, PlugAuth->VERSION, "client.version = @{[ PlugAuth->VERSION ]}";

__DATA__

@@ etc/PlugAuth.conf
---
url: <%= cluster->url %>
