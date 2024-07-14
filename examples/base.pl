#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

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
        'pagesize|p=i' => 2,
    };
}

sub debug {shift->opts->{'debug'}}
sub fork_count {shift->opts->{'forks'}}
sub limit {shift->opts->{'limit'}}


# required by Batcher
sub page_count {
    my $self = shift;
    # TODO: return number of pages in total result set
}

# required by Batcher
sub page_next {
    my ($self, $next_idx) = @_;
    # TODO: return the next page of results
}

# required by Batcher
sub page_size {
    my $self = shift;
    # TODO: return the number of results in a page
}

# required by Batcher
sub process_result {
    my ($self, $result) = @_;
    # TODO: something with the result ...
}

__PACKAGE__->new->run;
exit;