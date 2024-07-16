package Batcher;

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use POSIX qw(ceil);
use Time::HiRes qw(gettimeofday);

our $VERSION = '0.0.1';

sub new {
    my $self = shift;
    my $blsd = bless shift || {}, $self;
    $blsd;
}

sub debug { 0 }
sub forks { 4 }
sub logs  { 1 }

sub _process {
    my ($self, $batches) = @_;
    for my $batch (@{$batches}) {
        my $next_batch = $self->batch_next($batch);
        die "Return value of batch_next() must be an array ref!" unless ref $next_batch eq 'ARRAY';
        for my $result (@{$next_batch}) {
            $self->batch_result($result);
        }
    }
}

sub log {
    my ($self, $msg) = @_;
    say $msg if $self->logs;
}

sub _not_implemented_err {
    my ($self, $sub) = @_;
    $sub ||= (caller(1))[3];
    die "NotImplementedError: Derived package must implement sub '$sub'!\n";
}

sub batch_count {_not_implemented_err}
sub batch_next {_not_implemented_err}
sub batch_size {_not_implemented_err}
sub batch_result {_not_implemented_err}

sub run {
    my $self = shift;
    my $t0 = gettimeofday;
    my $batches = $self->batch_count;
    my $forks = $self->forks;
    my @batches = (0 .. $batches - 1);
    my $size = $self->batch_size;
    my $batches_per_fork = ceil($batches / $forks);

    $self->log("$forks forks, each processing $batches_per_fork batch(s) ($size results per batch)");

    my (@procs, @batch_groups);

    print Dumper "Batchs:", 0+@batches if $self->debug;
    die "Error: got batch count of 0.. check batch input source\n" if ! $batches;
    push @batch_groups, [splice @batches, 0, $batches_per_fork] while @batches;
    print Dumper "Batch groups", @batch_groups if $self->debug;

    for my $i (0 .. $forks - 1) {
        my $pid = fork // do {
            warn "Fork failed!: $!";
            next;
        };
        if ($pid == 0) {
            exit if $i > $forks;
            $self->_process($batch_groups[$i]);
            exit;
        }
        push @procs, $pid;
    }

    $self->log("Waiting for $forks forks to complete");

    for my $pid (@procs) {
        my $child = waitpid $pid, 0;
        $self->log("$child completed (code: $?)");
    }
    my $t1 = gettimeofday;
    my $elapsed = $t1 - $t0;
    say "elapsed: $elapsed";
}


1;

