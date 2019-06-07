package RouteMap::Model::TownNetwork;

use strict;
use Mojo::JSON "decode_json";
use Graph::Easy;

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

    my $g = Graph::Easy->new(undirected => "true");
    
#    foreach ($map->{'nodes'}){
#       $g->add_node("$_"); 
#    }
## debug
$g->add_edge('A', 'B');
$g->add_edge('C', 'B');
$g->add_edge('A', 'D');
$g->add_edge('D', 'C');
$g->add_edge('F', 'C');
$g->add_edge('D', 'F');


    return $g->as_boxart();

}


1;
