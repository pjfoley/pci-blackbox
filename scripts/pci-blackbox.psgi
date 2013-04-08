#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;

use DBI;
use DBD::Pg;
use DBIx::Pg::CallFunction;
use JSON;
use Plack::Request;

my $app = sub {
    my $env = shift;

    my $invalid_request = [
        '400',
        [ 'Content-Type' => 'application/json; charset=utf-8' ],
        [ to_json({
            jsonrpc => '2.0',
            error => {
                code => -32600,
                message => 'Invalid Request.'
            },
            id => undef
        }, {pretty => 1}) ]
    ];

    my ($method, $params, $id, $version, $jsonrpc);

    if ($env->{REQUEST_METHOD} eq 'GET') {
        my $req = Plack::Request->new($env);
        $method = $req->path_info;
        $method =~ s{^.*/}{};
        $params = $req->query_parameters->mixed;
        foreach my $k (keys %{$params}) {
            $params->{$k} = undef if $params->{$k} eq '';
        }
    } elsif ($env->{REQUEST_METHOD} eq 'POST' &&
        $env->{HTTP_ACCEPT} eq 'application/json' &&
        $env->{CONTENT_TYPE} =~ m!^application/json!
    ) {
        my $json_input;
        $env->{'psgi.input'}->read($json_input, $env->{CONTENT_LENGTH});
        my $json_rpc_request = from_json($json_input);

        $method  = $json_rpc_request->{method};
        $params  = $json_rpc_request->{params};
        $id      = $json_rpc_request->{id};
        $version = $json_rpc_request->{version};
        $jsonrpc = $json_rpc_request->{jsonrpc};
    } else {
        return $invalid_request;
    }

    unless ($method =~ m/
        ^
        (?:
            ([a-zA-Z_][a-zA-Z0-9_]*) # namespace
        \.)?
        ([a-zA-Z_][a-zA-Z0-9_]*) # function name
        $
    /x && (!defined $params || ref($params) eq 'HASH')) {
        return $invalid_request;
    }
    my ($namespace, $function_name) = ($1, $2);

    foreach my $k ('REMOTE_ADDR','HTTP_USER_AGENT','HTTP_ACCEPT') {
        if (exists $params->{lc($k)}) {
            $params->{lc($k)} = $env->{$k};
        }
    }

    my $callback;
    if (exists $params->{callback}) {
        $callback = delete $params->{callback};
        if (exists $params->{_}) {
            delete $params->{_};
        }
    }

    my $service = $env->{'psgi.input'}->dir_config('pg_service_name');
    my $dbh = DBI->connect("dbi:Pg:service=$service", '', '', {pg_enable_utf8 => 1}) or die "unable to connect to PostgreSQL";
    my $pg = DBIx::Pg::CallFunction->new($dbh);
    my $prefixed_params = {};
    foreach my $k (keys %{$params}) {
        $prefixed_params->{"_$k"} = $params->{$k};
    }
    my $result = $pg->$function_name($prefixed_params, $namespace);
    $dbh->disconnect;

    my $response = {
        result => $result,
        error  => undef
    };
    if (defined $id) {
        $response->{id} = $id;
    }
    if (defined $version && $version eq '1.1') {
        $response->{version} = $version;
    }
    if (defined $jsonrpc && $jsonrpc eq '2.0') {
        $response->{jsonrpc} = $jsonrpc;
        delete $response->{error};
    }

    if ($callback) {
        return [
            '200',
            [ 'Content-Type' => 'application/javascript; charset=utf-8' ],
            [ $callback . '(' . to_json($response->{result}, {pretty => 1}) . ');' ]
        ];
    } else {
        return [
            '200',
            [ 'Content-Type' => 'application/json; charset=utf-8' ],
            [ to_json($response, {pretty => 1}) ]
        ];
    }
};

__END__
