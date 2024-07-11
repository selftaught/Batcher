package MotherForker;

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use Getopt::Long;

sub new {
    my $self = shift;
    my $vals = shift // {opts => {}};
    my $blsd = bless $vals, $self;

    $blsd->_get_opts;
    $blsd;
}

sub _get_opts {
    my $self = shift;
    my %get_opts = ();
    for my $k (keys %{$self->option_params}) {
        my ($long, $short, $type) = $k =~ /^([^|]+)[|]([^=]+)([=]\w)?$/g;
        my $val = $self->option_params->{$k};
        if (!defined $self->options->{$k}) {
            $self->{'opts'}->{$k} = $val;
        }
        $get_opts{$k} = \$self->{opts}->{$long};
    }
    GetOptions(%get_opts);
}

sub option_params {
    return {
        'forks|f=i' => 10,
        'limit|l=i' => 0,
        'dryrun|d'  => 1,
    };
}

sub options {
    my $self = shift;
    return $self->{'opts'};
}

sub fork_count {shift->options->{'forks'}}
sub dryrun {shift->options->{'dry_run'}}
sub limit {shift->options->{'limit'}}

sub _fork {
    my ($self, $pages) = @_;
    for my $page (@{$pages}) {
        my $next_page = $self->page_next($page);
        for my $result (@{$next_page}) {
            $self->process_result($result);
        }
    }
}

sub log {
    my ($self, $msg, $stream) = @_;
    $stream ||= STDOUT;
    say $stream $msg;
}

sub page_count { die "Derived package must implement sub page_count!" }
sub page_next { die "Derived package must implement sub page_next!" }
sub page_size { die "Derived package must implement sub page_size!" }

sub main {
    my $self  = shift;
    my $pages = $self->page_count;
    my $forks = $self->fork_count;
    my @pages = (0 .. $pages - 1);

    print Dumper $self;

    my $per_child = $pages / $forks;

    $self->log("Spawning $forks forks to process $per_child pages each");

    my (@procs, @page_groups);

    push @page_groups, [splice @pages, 0, $per_child] while @pages;

    for my $i (0 .. $forks) {
        my $pid = fork // do {
            warn "Fork failed!: $!";
            next;
        };
        if ($pid == 0) {
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
