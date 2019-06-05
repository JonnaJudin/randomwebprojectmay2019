use Test::More;
use Test::Mojo;

# include application and modules
use FindBin;
require "$FindBin::Bin/../routemap.pl";
use lib "$FindBin::Bin/../lib";
use RouteMap::Model::TownNetwork;

# init test env
my $t = Test::Mojo->new;
my $class = 'RouteMap::Model::TownNetwork';
require_ok "$class";
can_ok($class, 'new');
my $b = $class->new;

# Allow 302 redirect response
$t->ua->max_redirects(1);

### Web Page
# Test if we have anything
$t->get_ok('/')->status_is(200);


### backend
isa_ok($b, 'RouteMap::Model::TownNetwork');
		
done_testing();

