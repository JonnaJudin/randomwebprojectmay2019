package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use utf8;
binmode STDOUT, ":utf8";

sub new {
    my $class = shift;
    my $self = {};

    bless $self, $class;

    return $self;
}

sub loadDB {
    my $json;
    local $/;
    open my $file, "<", "towns.json";
    $json = <$file>;
    close $file;

    my $db = decode_json $json;
    return $db;
}

sub initMap {
    return loadDB();
}


1;
