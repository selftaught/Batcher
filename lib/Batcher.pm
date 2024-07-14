package Batcher;

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use POSIX qw(ceil);

sub new {
    my $self = shift;
    my $vals = shift // {opts => {}};
    my $blsd = bless $vals, $self;
    $blsd;
}

sub debug { 0 }
sub fork_count { 4 }

sub _fork {
    my ($self, $pages) = @_;
    for my $page (@{$pages}) {
        my $next_page = $self->page_next($page);
        die "Return value of page_next($page) must be an array ref!" unless ref $next_page eq 'ARRAY';
        for my $result (@{$next_page}) {
            $self->process_result($result);
        }
    }
}

sub log {
    my ($self, $msg) = @_;
    say $msg;
}

sub _not_implemented_err {
    my ($self, $sub) = @_;
    $sub ||= (caller(1))[3];
    die "NotImplemented: Derived package must implement sub '$sub'!\n";
}

sub page_count { _not_implemented_err() }
sub page_next { _not_implemented_err() }
sub page_size { _not_implemented_err() }

sub run {
    my $self  = shift;
    my $pages = $self->page_count;
    my $forks = $self->fork_count;
    my @pages = (0 .. $pages - 1);
    my $size  = $self->page_size;
    my $pages_per_fork = ceil($pages / $forks);

    $self->log("$forks forks, each processing $pages_per_fork page(s) ($size results per page)");

    my (@procs, @page_groups);

    print Dumper "Pages:", @pages if $self->debug;
    push @page_groups, [splice @pages, 0, $pages_per_fork] while @pages;

    if ($self->debug) {
        print Dumper "Page groups", @page_groups;
    }

    for my $i (0 .. $forks - 1) {
        my $pid = fork // do {
            warn "Fork failed!: $!";
            next;
        };
        if ($pid == 0) {
            exit if $i > $forks;
            $self->_fork($page_groups[$i]);
            exit;
        }
        push @procs, $pid;
    }

    $self->log("Starting " . scalar @procs . " child processes");

    for my $pid (@procs) {
        my $child = waitpid $pid, 0;
        $self->log("$child exited with $?");
    }
}


1;

