# PlugAuth::Client::Tiny [![Build Status](https://secure.travis-ci.org/clustericious/PlugAuth-Client-Tiny.png)](http://travis-ci.org/clustericious/PlugAuth-Client-Tiny)

Minimal PlugAuth client

# SYNOPSIS

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

# DESCRIPTION

PlugAuth::Client::Tiny is a minimal [PlugAuth](https://metacpan.org/pod/PlugAuth) client.  It uses [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) 
instead of [LWP](https://metacpan.org/pod/LWP) or [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent).  It provides only a mechanism for
authenticating and authorizing against a [PlugAuth](https://metacpan.org/pod/PlugAuth) server.  If you need to
modify the users/groups/authorization on the server through the RESTful API
then you will need the heavier [PlugAuth::Client](https://metacpan.org/pod/PlugAuth::Client) which relies on 
[Clustericious::Client](https://metacpan.org/pod/Clustericious::Client) and [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent).

PlugAuth::Client::Tiny should work perfectly with [PlugAuth::Lite](https://metacpan.org/pod/PlugAuth::Lite) as well, 
because it only uses the subset of the PlugAuth API which is implemented by
[PlugAuth::Lite](https://metacpan.org/pod/PlugAuth::Lite).

# CONSTRUCTOR

## new

    use PlugAuth::Client::Tiny->new;
    my $client = PlugAuth::Client::Tiny->new;

PlugAuth::Client::Tiny's constructor accepts one optional option:

- url

    The URL of the [PlugAuth](https://metacpan.org/pod/PlugAuth) server.  If not specified, `http://localhost:3000`
    is used.

All other options passed to `new` will be passed on to the constructor of [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny),
which allows you to set `agent`, `default_headers`, etc.  See the documentation of
[HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) for details.

# ATTRIBUTES

## url

    my $url = $client->url;

Returns the URL for the [PlugAuth](https://metacpan.org/pod/PlugAuth) server.  This attribute is read-only.

# METHODS

## auth

    my $bool = $client->auth( $user, $password );

Attempt to authenticate against the [PlugAuth](https://metacpan.org/pod/PlugAuth) server using the given username and password.
Returns 1 on success, 0 on failure and dies on a connection failure.

## authz

    my $bool = $client->authz( $user, $action, $resource );

Determine if the given user is authorized to perform the given action on the given resource.
Returns 1 on success, 0 on failure and dies on connection failure.

## version

    my $version = $client->version;

Returns the version of the [PlugAuth](https://metacpan.org/pod/PlugAuth) server.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
