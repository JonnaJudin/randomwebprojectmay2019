package RouteMap::Model::TownNetwork;

use strict;
use JSON::XS;

sub new { bless {}, shift }

sub initMap {
	my @nodes = ["Helsinki", "Turku"];
	my @roads = [{start => "Helsinki", end => "Turku", Color => "Green"}];

	my $j = JSON::XS->new->utf8->pretty(1);
	my $out = $j->encode({nodes => @nodes, edges => @roads});

	return $out;
}

1;
