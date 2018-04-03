use Mojolicious::Lite;

my $client_id = 'batman';
my $client_secret = 'robin';
plugin 'OAuth2::Server' => {
    clients => {
        $client_id => {
            client_secret => $client_secret,
            scopes        => {
                eat   => 1,
                drink => 0,
                sleep => 1,
            },
        },
    },
};

group {
    # /api - must be authorized
    under '/api' => sub {
        my ($c) = @_;

        return 1 if $c->oauth;    # must be authorized via oauth

        $c->render( status => 401, text => 'Unauthorized' );
        return undef;
    };

    any '/annoy_friends' => sub { shift->render( text => "Annoyed Friends" ); };
    any '/post_image'    => sub { shift->render( text => "Posted Image" ); };
};

any '/track_location' => sub {
    my ($c) = @_;

    my $oauth_details = $c->oauth('track_location')
        || return $c->render( status => 401, text => 'You cannot track location' );

    $c->render( text => "Target acquired: @{[$oauth_details->{user_id}]}" );
};

app->start;
