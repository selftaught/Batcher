package Test::Batcher;

use strict;
use warnings;
use feature 'say';

# use FindBin qw($Bin);
use lib "..";
use parent 'Batcher';


sub new {
    my $self = shift;
    my $vals = shift // {};
    my $blsd = bless $vals, $self;

    return $blsd;
}

sub debug {
    my ($self, $debug) = @_;
    if ($debug) {
        $self->{'_debug'} = $debug;
        return;
    }
    return $self->{'_debug'} // $self->SUPER::debug();
}

sub batch_count {
    my ($self, $count) = @_;
    $self->{'batch_count'} = $count if $count;
    $self->{'batch_count'};
}

sub batch_size {
    my ($self, $size) = @_;
    $self->{'batch_size'} = $size if $size;
    $self->{'batch_size'};
}

sub batch_next {
    my ($self, $next_idx, $next) = @_;
    $self->{'batch_next'} = $next if $next;
    $self->{'batch_next'};
}

sub batch_result {
    my ($self, $result) = @_;
}

sub forks {
    my ($self, $forks) = @_;
    $self->{'forks'} = $forks if $forks;
    $self->{'forks'};
}

1;