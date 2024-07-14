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
        'file|f=s' => undef,
        'forks|f=i' => 10,
        'limit|l=i' => 0,
        'pagesize|p=i' => 2,
    };
}

sub csv_file {shift->opts->{'file'}}
sub debug {shift->opts->{'debug'}}
sub fork_count {shift->opts->{'forks'}}
sub limit {shift->opts->{'limit'}}

sub csv_read {
    my $self = shift;
    my $header = undef;
    my @lines = ();
    open my $fh, '<', $self->csv_file or die "Couldn't open csv file!: $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        if (! defined $header) {
            $header = $line;
            next;
        }
        push @lines, $line;
    }
    close $fh;
    return @lines;
}

# required by Batcher
sub page_count {
    my $self = shift;
    my @lines = $self->csv_read;
    my $page_count = ceil(scalar @lines / $self->page_size);
    return $page_count;
}

# required by Batcher
sub page_next {
    my ($self, $next_idx) = @_;
    my @lines = $self->csv_read;
    my $page_size = $self->page_size;
    my $page = [splice @lines, $next_idx * $self->page_size, $page_size];
    return $page;
}

# required by Batcher
sub page_size {shift->opts->{'pagesize'}}

# required by Batcher
sub process_result {
    my ($self, $result) = @_;
    print "($$) result: $result\n";
    # Do something with the result ...
}

__PACKAGE__->new->run;
exit;