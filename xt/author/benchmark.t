use strict;
use warnings;
use Test::More;
use File::Which qw(which);
use Benchmark qw(countit);
use CSS::Minifier::XS;

###############################################################################
# Only run Benchmark if asked for.
unless ($ENV{BENCHMARK}) {
    plan skip_all => 'Skipping Benchmark; use BENCHMARK=1 to run';
}

###############################################################################
# check if CSS::Minifier available, so we can do a benchmark comparison
eval { require CSS::Minifier };
if ($@) {
    plan skip_all => 'CSS::Minifier not available for benchmark comparison';
}

###############################################################################
# What CSS docs do we want to try compressing?
my $curl = which('curl');
my @libs = qw(
    https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.css
    https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.css
);

###############################################################################
# time test the PurePerl version against the XS version.
compare_benchmark: {
    my $count;
    my $time = 10;

    # build up a big CSS document to minify
    my $str = join "\n", map { qx{$curl --silent $_} } @libs;

    # benchmark the original "pure perl" version
    $count = countit( $time, sub { CSS::Minifier::minify(input=>$str) } );
    my $rate_pp = ($count->iters() / $time) * length($str);

    # benchmark the "XS" version
    $count = countit( $time, sub { CSS::Minifier::XS::minify($str) } );
    my $rate_xs = ($count->iters() / $time) * length($str);

    ok( 1, "benchmarking" );
    diag( "" );
    diag( "Benchmark results:" );
    diag( "\tperl\t=> $rate_pp bytes/sec" );
    diag( "\txs\t=> $rate_xs bytes/sec" );
}

###############################################################################
done_testing();
