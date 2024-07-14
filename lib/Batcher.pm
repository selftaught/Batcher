package Batcher;

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use POSIX qw(ceil);

sub new {
    my $self = shift;
    my $vals = shift || {};
    my $blsd = bless $vals, $self;
    $blsd;
}

sub debug { 0 }
sub forks { 4 }
sub logs  { 1 }

sub _fork {
    my ($self, $pages) = @_;
    for my $page (@{$pages}) {
        my $next_page = $self->batch_next($page);
        die "Return value of batch_next() must be an array ref!" unless ref $next_page eq 'ARRAY';
        for my $result (@{$next_page}) {
            $self->process_result($result);
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
sub process_result {_not_implemented_err}

sub run {
    my $self  = shift;
    my $pages = $self->batch_count;
    my $forks = $self->forks;
    my @pages = (0 .. $pages - 1);
    my $size  = $self->batch_size;
    my $pages_per_fork = ceil($pages / $forks);

    $self->log("$forks forks, each processing $pages_per_fork page(s) ($size results per page)");

    my (@procs, @batch_groups);

    print Dumper "Pages:", @pages if $self->debug;
    die "Error: got 0 for page count - exiting..\n" if ! $pages;
    push @batch_groups, [splice @pages, 0, $pages_per_fork] while @pages;
    print Dumper "Page groups", @batch_groups if $self->debug;

    for my $i (0 .. $forks - 1) {
        my $pid = fork // do {
            warn "Fork failed!: $!";
            next;
        };
        if ($pid == 0) {
            exit if $i > $forks;
            $self->_fork($batch_groups[$i]);
            exit;
        }
        push @procs, $pid;
    }

    $self->log("Waiting for $forks forks to complete");

    for my $pid (@procs) {
        my $child = waitpid $pid, 0;
        $self->log("$child completed (code: $?)");
    }
}


1;

