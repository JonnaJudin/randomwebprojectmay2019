package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use Graph::Easy;
use Graph::Easy::As_svg;
use Data::Dump "dump";

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
    my $map = loadDB();

    my $g = Graph::Easy->new(undirected => 1);
    my @towns = @{$map->{"nodes"} };    
    foreach (@towns){
       $g->add_node("$_"); 
    }
    my @roads = @{ $map->{"edges"} };
    foreach (@roads){
        my $start = $_->{"start"};
        my $end = $_->{"end"};
        my $color = $_->{"color"};
        my $edge = $g->add_edge_once($start, $end);
        if(defined $edge){
                    $edge->set_attribute('color', $color);
        }
    }
    return $g->as_svg();
}


1;
