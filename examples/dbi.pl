#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use POSIX qw(ceil);
use FindBin qw($Bin);
use lib qq{$Bin/../lib};

use parent 'Batcher';

sub new {
    my $self = shift;
    my $vals = shift // {_opts => {}};
    my $blsd = bless $vals, $self;

    $blsd->_get_opts;
    $blsd;
}

sub opts {shift->{'_opts'}}

sub _get_opts {
    my $self = shift;
    my %get_opts = ();
    for my $k (keys %{$self->option_params}) {
        my ($long, $short, $type) = $k =~ /^([^|]+)(?:[|]([^=]+))?([=]\w)?$/g;
        my $default_val = $self->option_params->{$k};
        if (!defined $self->opts->{$long}) {
            $self->{'_opts'}->{$long} = $default_val;
        }
        $get_opts{$k} = \$self->{'_opts'}->{$long};
    }
    GetOptions(%get_opts);
}

sub option_params {
    return {
        'debug|D' => 0,
        'forks|f=i' => 10,
        'limit|l=i' => 0,
        'batchsize|s=i' => 2,
    };
}

sub debug {shift->opts->{'debug'}}
sub forks {shift->opts->{'forks'}}
sub limit {shift->opts->{'limit'}}

sub db {
    my $self = shift;
}

# required by Batcher
sub batch_count {
    my $self = shift;
    # TODO: return number of batchs in total result set
    if (!defined $count) {
        # $count = SELECT COUNT(*) FROM table
    }
    # return ceil()
}

# required by Batcher
sub batch_next {
    my ($self, $next_idx) = @_;
    # TODO: return the next batch of results
}

# required by Batcher
sub batch_size {
    # TODO: return the number of results in a batch
}

# required by Batcher
sub batch_result {
    my ($self, $result) = @_;
    # TODO: something with the result ...
}

__PACKAGE__->new->run;
exit;