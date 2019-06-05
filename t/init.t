use Test::More;
use Test::Mojo;

# include application and modules
use FindBin;
require "$FindBin::Bin/../routemap.pl";
use lib "$FindBin::Bin/../lib";
use RouteMap::Model::TownNetwork;

# init test env
my $t = Test::Mojo->new;
# Allow 302 redirect response
$t->ua->max_redirects(1);

my $class = 'RouteMap::Model::TownNetwork';

#############
# 
# testcases
#
#############
$tc = 0;

$tc++;
print("### Test $tc ###\n");
print(">>> Access pm file");
print("\n\n");
require_ok "$class";

$tc++;
print("### Test $tc ###\n");
print(">> Can we connect to app");
print("\n\n");
$t->get_ok('/')->status_is(200);


### backend
$tc++;
print("### Test $tc ###\n");
print(">>> Can we call new");
print("\n\n");
can_ok($class, 'new');
my $b = $class->new;

$tc++;
print("### Test $tc ###\n");
print(">> was new successful");
print("\n\n");
isa_ok($b, 'RouteMap::Model::TownNetwork');

$tc++;
print("### Test $tc ###\n");
print(">> Can we connect to app");
print("\n\n");
my $db = $b->loadDB; ok( $b->can('loadDB'), 'Database loading possible');
isnt($db, undef, 'Does DB object exist') or diag("db object undefined");
print $db->{'nodes'}->[0] . "\n";
print $db->{'nodes'}->[1] . "\n";
		
done_testing();

