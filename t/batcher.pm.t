#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use Test::Exception;
use Test::Batcher;
use Test::MockModule;
use Test::More;
use Time::HiRes qw(usleep gettimeofday);

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Batcher;



subtest 'Defaults' => sub {
    my $b = Batcher->new;

    is $b->debug, 0, 'debug default is 0';
    is $b->forks, 4, 'forks default is 4';
    is $b->logging, 1, 'logging is enabled by default';
};

subtest 'Required hooks' => sub {
    my $b = Batcher->new;

    throws_ok { $b->batch_count } qr/NotImplementedError/;
    throws_ok { $b->batch_next } qr/NotImplementedError/;
    throws_ok { $b->batch_size } qr/NotImplementedError/;
    throws_ok { $b->batch_result } qr/NotImplementedError/;
};

subtest 'Performance' => sub {
    my $mock = Test::MockModule->new('Test::Batcher');
    my $io_micro_secs = 1000 * 1; # 10ms
    my $io_delay_ms = $io_micro_secs / 100;
    my $microsecs_to_sec = 1_000_000;
    my $io_delay_sec = 1;

    $mock->mock('batch_result', sub { sleep $io_delay_sec; }); #usleep $io_micro_secs });
    $mock->mock('logging', sub {0});

    # case 1
    my $args = {
        #_debug => 1,
        batch_count => 1,
        batch_next => [('https://dillan.io')],
        batch_size => 1,
        forks => 1,
    };

    my $test_msg = sub {
        my ($args, $delay, $elapsed) = @_;
        my $task_cnt = $args->{'batch_count'} * $args->{'batch_size'};
        return sprintf "%d (%d sec delay) tasks in %d forks took %.2f seconds", $task_cnt, $delay, $args->{'forks'}, $elapsed;
    };

    # CASE 1
    my $margin = .1;
    my $test_batcher = Test::Batcher->new($args);
    my $start = gettimeofday;
    $test_batcher->run;
    my $elapsed = gettimeofday - $start;
    my $expected_min = 1;
    my $expected_max = $expected_min + $margin;
    #diag "1 task, 1 fork, 1 sec delay - elapsed: $elapsed";
    ok $elapsed >= $expected_min && $elapsed <= $expected_max, $test_msg->($args, $io_delay_sec, $elapsed);

    # CASE 2
    $args->{'batch_count'} = 2;
    $args->{'batch_size'} = 1;
    $args->{'forks'} = 2;
    $test_batcher = Test::Batcher->new($args);
    $start = gettimeofday;
    $test_batcher->run;
    $elapsed = gettimeofday - $start;
    ok $elapsed >= $expected_min && $elapsed <= $expected_max, $test_msg->($args, $io_delay_sec, $elapsed);
    #diag "2 task, 2 fork, 1 sec delay - elapsed: $elapsed";
};


done_testing();