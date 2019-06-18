package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use Graph;
use Graph::Undirected;
use Graph::Easy;
use Data::Dump "dump";

use utf8;
binmode STDOUT, ":utf8";

sub new {
    my $class = shift;
    # object used for calculations
    my $graph = Graph::Undirected->new();
    # object used to get simple output
    my $simple = Graph::Easy->new();

    my $rawData = loadDB();

    my $self = bless {
                       graphData => $graph,
                       rawData => $rawData,
                       simple => $simple,
                       initStatus => 0,
               }, $class;

    return $self;
}

# getters

sub graphData {
    my $self = shift;
    return $self->{graphData};
}

sub rawData {
    my $self = shift;
    return $self->{rawData};
}

sub simple {
    my $self = shift;
    return $self->{'simple'};
}

sub getAllTowns {
    my $self = shift;
    my $towns = $self->rawData->{'nodes'};
    return $towns;
}

sub getTown {
    my $self = shift;
    return $self->rawData->{'nodes'}[0];
}

# load town data from fixed file name of type json
sub loadDB {
    # slurp the file
    local $/;
    open my $file, "<", "towns.json";
    my $json = <$file>;
    close $file;

    # transfer into perl object
    my $db = decode_json $json;
    return $db;
}

# did we load the map already?
sub initDone {
    my $self = shift;
    if (@_ == 1) {
        $self->{initStatus} = shift;
    }
    return $self->{'initStatus'};
}

# transform the data into Graph object
sub initMap {
    my $self = shift;
    my $map = $self->rawData;

    # get list of each node
    my @towns = @{$map->{"nodes"} };    
    # add each node to both graphs
    foreach (@towns){
       $self->graphData->add_vertex("$_"); 
       $self->simple->add_node("$_");
    }

    # get all specified roads
    my @roads = @{ $map->{"edges"} };
    foreach (@roads){
        my $start = $_->{"start"};
        my $end = $_->{"end"};
        $self->graphData->add_weighted_edge($start, $end, 1);
        # store the color data as we need it later
        $self->graphData->set_edge_attribute($start, $end, 'color', $_->{"color"});
        my $edge = $self->simple->add_edge_once($start, $end);
        if (defined $edge) {
            $edge->set_attribute('color', $_->{"color"});
        }
    }

    $self->initDone(1);
}

# set different weights to edges from params
sub updateWeights {
    my $self = shift;
    my ($red, $green, $blue) = @_;
    my %values = ( 'red' => $red, 'green' => $green, 'blue' => $blue);
    foreach ($self->graphData->edges()){
        # let's keep this readable
        my $start = $_->[0];
        my $end   = $_->[1];
        # get color for current edge
        my $color = $self->graphData->get_edge_attribute($start, $end, 'color');
        # get new value and replace old one
        my $newVal = $values{$color};
        $self->graphData->set_edge_attribute($start, $end, 'weight', $newVal);
    }
}

# Where the magic happens
sub calculateRoute {
    my ($self, $origin, $r, $g, $b) = @_;

    # maybe we got called from a bookmark or something
    $self->initMap unless $self->initDone;
    
    # use given values for route calculation
    $self->updateWeights($r, $g, $b);
    
    # only sure route so far is to go nowhere
    my $end = $origin;

    # get all shortest paths
    my $apsp = $self->graphData->APSP_Floyd_Warshall();
    my $longestpath = 0;

    # get all possible endpoints where we could go
    my @all = @{ $self->getAllTowns };
    # find longest shortest path between origin and all nodes 
    # to cover more space on first run through
    foreach (@all){
       my $currentlength = $apsp->path_length($origin, $_); 
       # if this is further out than any before, store it
       if ($currentlength > $longestpath){
            $end = $_;
            $longestpath = $currentlength;
       }
    }
    dump "ENDPOINT: " . $end;

    # we need some gfx so using easy
    my $path = Graph::Easy->new();
    my $totalLength = 0;
    my @v = $apsp->path_vertices($origin, $end);
    my @seen;
    # we've already seen the starting point
    push (@seen, $v[0]);
    # go through every node on path and mark it as seen
    for (my $i = 1; $v[$i]; $i++){
        push(@seen, $v[$i]);
        $path->add_edge($v[$i-1], $v[$i]);
        $totalLength += $apsp->path_length($v[$i-1], $v[$i]);
    }

    # take note of nodes not yet visited
    my @unseen;

    foreach my $val (@all){
        if (grep( /^$val$/, @seen )){
            dump "seen $val";
        }
        else {
            dump "haven't seen $val before";
            push(@unseen, $val);
        }
    }

    #####
    # TODO:
    # if unvisited nodes
    #   use BFS to find next unvisited node
    #       get shortest path to any of the visited nodes
    #       add trip there and back to total (not very cost effective)
    #       keep going until all nodes visited

    return ($path->as_svg(), $totalLength);
}

sub output {
    my $self = shift;
    my $output = $self->simple->as_svg();
    return $output;
}

1;
