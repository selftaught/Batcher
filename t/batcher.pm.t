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

# subtest 'Performance' => sub {
#     is 1, 1;
#     my $mock = Test::MockModule->new('Test::Batcher');
#     my $io_micro_secs = 1000 * 5; # 50ms
#     $mock->mock('batch_result', sub {
#         my ($self, $result) = @_;
#         # say $result;
#         usleep $io_micro_secs;
#         #sleep 1;
#     });
#     $mock->mock('logging', sub {0});

#     my $fork_max = 15;
#     say "io_micro_secs_delay,forks,batch_count,batch_size,elapsed";
#     for (my $i = 1; $i <= $fork_max; $i++) {
#         for (my $j = 0; $j < 10; $j++) {
#             my $batch_count = 30;
#             my $batch_next = [('https://dillan.io') x 10];
#             my $batch_size = 2;
#             my $forks = $i;
#             my $batcher = Test::Batcher->new({
#                 batch_count => $batch_count,
#                 batch_next => $batch_next,
#                 batch_size => $batch_size,
#                 #_debug => 1,
#                 forks => $forks,
#             });
#             my $start = gettimeofday;
#             $batcher->run;
#             my $stop = gettimeofday;
#             my $elapsed = $stop - $start;
#             #print Dumper $elapsed;
#             say "$io_micro_secs,$forks,$batch_count,$batch_size,$elapsed";
#         }
#     }

# };


done_testing();