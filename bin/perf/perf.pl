#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Batcher;
use Data::Dumper;
use Getopt::Long;
use Graph;
use Test::Exception;
use Test::Batcher;
use Test::MockModule;
use Test::More;
use Time::HiRes qw(usleep gettimeofday time);


my $mock = Test::MockModule->new('Test::Batcher');
my $io_micro_secs = 1000 * 5; # 50ms
my $io_ms = $io_micro_secs / 1000;
$mock->mock('batch_result', sub {
    my ($self, $result) = @_;
    usleep $io_micro_secs;
});
$mock->mock('logging', sub {0});

my $fork_max = 40;
my $iters_per_fork = 5; # just runs the same iteration N (2) number of times
my $batch_count = 30;
my $batch_size = 2; # 2 items to process in each batch
my $batch_next = [('https://dillan.io') x $batch_size];

say "io_ms_delay,forks,batch_count,batch_size,elapsed,time";
for (my $i = 1; $i <= $fork_max; $i++) {
    for (my $j = 0; $j < $iters_per_fork; $j++) {
        my $forks = $i;
        my $batcher = Test::Batcher->new({
            batch_count => $batch_count,
            batch_next => $batch_next,
            batch_size => $batch_size,
            forks => $forks,
        });
        my $start = gettimeofday;
        $batcher->run;
        my $stop = gettimeofday;
        my $elapsed = $stop - $start;
        #print Dumper $elapsed;
        say sprintf "%s,%i,%i,%i,%.04f,%.04f", "${io_ms}ms",$forks,$batch_count,$batch_size,$elapsed,time;
    }
}