package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use Graph;
use Graph::Undirected;
use Graph::Convert;
use Graph::Easy;
use Graph::Easy::As_svg;
use Data::Dump "dump";

use utf8;
binmode STDOUT, ":utf8";

sub new {
    my $class = shift;
    my $graph = Graph::Undirected->new();
    my $rawData = loadDB();

    my $self = bless {
                       graphData => $graph,
                       rawData => $rawData,
               }, $class;

    return $self;
}

sub graphData {
    my $self = shift;
    return $self->{graphData};
}

sub rawData {
    my $self = shift;
    return $self->{rawData};
}

sub loadDB {
    local $/;
    open my $file, "<", "towns.json";
    my $json = <$file>;
    close $file;

    my $db = decode_json $json;
    return $db;
}

sub initMap {
    my $self = shift;
    my $map = $self->rawData;
    

    my @towns = @{$map->{"nodes"} };    
    foreach (@towns){
       $self->graphData->add_vertex("$_"); 
    }

    my @roads = @{ $map->{"edges"} };
    foreach (@roads){
        my $start = $_->{"start"};
        my $end = $_->{"end"};
        $self->graphData->set_edge_attribute($start, $end, 'weight', 1);
        $self->graphData->set_edge_attribute($start, $end, 'color', $_->{"color"});
    }

    print "\n$map\n";
    return "$map";
}

sub calculateRoute {
    my ($self, $origin, $r, $g, $b) = @_;
    my %details = ('red' => $r, 'green' => $g, 'blue' => $b);
# REMOVE
$self->loadDB;
$self->initMap;
    my $path = $self->graphData->SPT_Dijkstra($origin);
    my $clean = $path->copy_graph;
    # my $ge = Graph::Convert->as_graph_easy( $clean  );
    my $ge = Graph::Convert->as_graph_easy($clean);

    return $ge->as_svg();
}


1;
