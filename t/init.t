use Test::More;
use Test::Mojo;

# include application
use FindBin;
require "$FindBin::Bin/../routemap.pl";

# Allow 302 redirect responss
my $t = Test::Mojo->new;
$t->ua->max_redirects(1);

# Test if we have anything
$t->get_ok('/')
	->status_is(200);

done_testing();

