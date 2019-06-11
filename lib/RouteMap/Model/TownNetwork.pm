package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use Graph;
use Graph::Undirected;
use Graph::Traversal::BFS;
use Graph::D3;
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
                       initStatus => 0,
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

sub getAllTowns {
    my $self = shift;
    return $self->rawData->{'nodes'};
}

sub getTown {
    my $self = shift;
    return $self->rawData->{'nodes'}[0];
}

sub loadDB {
    local $/;
    open my $file, "<", "towns.json";
    my $json = <$file>;
    close $file;

    my $db = decode_json $json;
    return $db;
}

sub initDone {
    my $self = shift;
    if (@_ == 1) {
        $self->{initStatus} = shift;
    }

    return $self->{'initStatus'};
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
        $self->graphData->add_weighted_edge($start, $end, 1);
        $self->graphData->set_edge_attribute($start, $end, 'color', $_->{"color"});
    }

    $self->initDone(1);
    return "$map";
}

sub updateWeights {
    my $self = shift;
    my ($red, $green, $blue) = @_;
    my %values = ( 'red' => $red, 'green' => $green, 'blue' => $blue);
    foreach ($self->graphData->edges()){
        # let's keep this readable
        my $start = $_->[0];
        my $end   = $_->[1];
        my $color = $self->graphData->get_edge_attribute($start, $end, 'color');
        my $newVal = $values{$color};
        $self->graphData->set_edge_attribute($start, $end, 'weight', $newVal);
    }
}

sub calculateRoute {
    my ($self, $origin, $r, $g, $b) = @_;
    $self->initMap unless $self->initDone;
    $self->updateWeights($r, $g, $b);
    my $path = Graph->new();
    $path->add_vertex($origin);
    my $end = $self->graphData->random_vertex();
    #####
    # Find longest shortest path from origin and add to path
    # if unvisited nodes
    #   current has unvisited neighbours?
    #       move to closest unvisited neighbour
    #   direct neighbour has unvisited neighbours?
    #       move to closest neigbour with unvisited ones
    # 
    my $apsp = $self->graphData->APSP_Floyd_Warshall();
# get_edge_weight(u,v)
    my @v = $apsp->path_vertices($origin, 'Tuupovaara');
    for (my $i = 1; $v[$i]; $i++){
        $path->add_edge($v[$i-1], $v[$i]);
    }
    dump @v;
    dump $path;
    my $bfs = Graph::Traversal::BFS->new($self->graphData, (start => $origin));
    my @d = $bfs->bfs;
    dump @d;
    return $path;
}

sub output {
    my $self = shift;
    return "$self->graphData";
}

1;
