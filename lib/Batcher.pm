package Batcher;

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use Getopt::Long;
use POSIX qw(ceil);

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
        my ($long, $short, $type) = $k =~ /^([^|]+)(?:[|]([^=]+))?([=]\w)?$/g;
        my $val = $self->option_params->{$k};
        if (!defined $self->opts->{$k}) {
            $self->{'opts'}->{$k} = $val;
        }
        $get_opts{$k} = \$self->{'opts'}->{$long};
    }
    GetOptions(%get_opts);
}

sub option_params {
    return {
        'forks|f=i' => 10,
        'limit|l=i' => 0,
        'dryrun|d' => 1,
        'debug|D' => 0,
    };
}

sub opts {
    my $self = shift;
    return $self->{'opts'};
}

sub debug {shift->opts->{'debug'}}
sub dryrun {shift->opts->{'dry_run'}}
sub help {shift->opts->{'help'}}
sub fork_count {shift->opts->{'forks'}}
sub limit {shift->opts->{'limit'}}

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

sub page_count { die "Derived package must implement sub page_count!" }
sub page_next { die "Derived package must implement sub page_next!" }
sub page_size { die "Derived package must implement sub page_size!" }

sub main {
    my $self  = shift;
    my $pages = $self->page_count;
    my $forks = $self->fork_count;
    my @pages = (0 .. $pages - 1);
    my $size  = $self->page_size;
    my $pages_per_fork = ceil($pages / $forks);

    $self->log("Creating $forks forks for $pages_per_fork pages ($size results per page)");

    my (@procs, @page_groups);

    push @page_groups, [splice @pages, 0, $pages_per_fork] while @pages;

    if ($self->debug) {
        print Dumper @page_groups;
        print Dumper @pages;
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

