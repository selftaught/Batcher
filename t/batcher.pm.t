#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

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

subtest 'Required hooks', sub {
    my $b = Batcher->new;

    throws_ok { $b->batch_count } qr/NotImplementedError/;
    throws_ok { $b->batch_next } qr/NotImplementedError/;
    throws_ok { $b->batch_size } qr/NotImplementedError/;
    throws_ok { $b->process_result } qr/NotImplementedError/;
};


done_testing();