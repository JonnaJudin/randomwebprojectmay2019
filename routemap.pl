#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use RouteMap::Model::TownNetwork;

# Helper to init our route model
helper route => sub {state $route = RouteMap::Model::TownNetwork->new };

any '/' => sub {
    my $c = shift;
    my $red   = $c->param('red')   || '';
    my $green = $c->param('green') || '';
    my $blue  = $c->param('blue')  || '';

    my $data = $c->route->loadDB;
    my $towns = $data->{'nodes'};
    my $graph = $c->route->initMap;
    $c->stash(
        towns => $towns,
        graph => $graph
        );
  
    return $c->render unless $red && $green && $blue;

} => 'index';

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Routemap';
%= stylesheet 'style.css'
<h1>Routemap<h1>
<div class="map">
    <h2>Map</h2>
<%== $graph %>
    <h2>========</h2>
</div>
<div id="colorinput">
   <h2>Insert time needed for each line in minutes:<h2>
   %= form_for index => begin
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
@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
