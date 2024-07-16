#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use Test::MockModule;
use Test::More;
use Test::Exception;
use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Batcher;


subtest 'Defaults' => sub {
    my $b = Batcher->new;

    is $b->debug, 0, 'debug default is 0';
    is $b->forks, 4, 'forks default is 4';
    is $b->logs, 1, 'logs default is 1';
};

subtest 'Required hooks' => sub {
    my $b = Batcher->new;

    throws_ok { $b->batch_count } qr/NotImplementedError/;
    throws_ok { $b->batch_next } qr/NotImplementedError/;
    throws_ok { $b->batch_size } qr/NotImplementedError/;
    throws_ok { $b->batch_result } qr/NotImplementedError/;
};

# subtest 'Performance' => sub {
#     my $b = Batcher->new;
#     is 1, 1;
#     my $batch_count = 100;
#     my $batch_next = 'https://dillan.io';

#     $b->run;
# };


done_testing();