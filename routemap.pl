#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use RouteMap::Model::TownNetwork;

# Helper to init our route model
helper route => sub {state $route = RouteMap::Model::TownNetwork->new };

get '/' => sub {
  my $c = shift;

  my $data = $c->route->initMap;
  $c->render(text => $data);
  

};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
