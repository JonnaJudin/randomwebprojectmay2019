#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use RouteMap::Model::TownNetwork;

# Helper to init our route model
helper route => sub {state $route = RouteMap::Model::TownNetwork->new };

any '/' => sub {
    my $c = shift;

    $c->route->initMap;
    my $towns = $c->route->rawData->{'nodes'};
    my $graph = $c->route->graphData;
    $c->stash(
        towns => $towns,
        graph => $graph
        );
  
    return $c->render;

} => 'index';

get '/route' => sub {
    my $c = shift;

    my $red   = $c->param('red')   || '1';
    my $green = $c->param('green') || '1';
    my $blue  = $c->param('blue')  || '1';
    my $town  = $c->param('town')  || $c->route->rawData->{'node'}[0];

    my $route = $c->route->calculateRoute($town, $red, $green, $blue);
    # TODO: save route at the object and use that
    $c->stash(route => $route);

    return $c->render;

} => 'route';

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Routemap';
%= stylesheet 'style.css'
<h1>Routemap<h1>
<div class="map" width="400">
    <h2>Map</h2>
    <h2>========</h2>
<%== $graph %>
    <h2>========</h2>
</div>
<div id="colorinput">
   <h2>Insert time needed for each line in minutes:<h2>
   %= form_for route => begin
           Red Line:
           %= text_field 'red'
           <br>Green Line: 
           %= text_field 'green'
           <br>Blue Line: 
           %= text_field 'blue'
           <br>
           <h3>Select starting town:</h3>
           Town: <br>
           %= select_field town => <%= $towns
           <br>
           %= submit_button 'Calculate Route', id => 'calculate'
   % end
</div>
@@ route.html.ep
% layout 'default';
% title 'Routemap';
%= stylesheet 'style.css'
<h1>Suggested route</h1>
<div class="map">
    <h2>========</h2>
<%== $route %>
    <h2>========</h2>
</div>
<div>
%= link_to 'Back to Main' => 'index'
</div>
@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
