#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Data::Dumper;
use FindBin qw($Bin);
use lib qq{$Bin/../../lib};

use parent 'MotherForker';


sub option_params {
    my $self = shift;
    my $parent_opts = $self->SUPER::option_params;
    return {
        %$parent_opts,
        'csvfile|f=s' => undef,
    }
}

sub csv_file {shift->options->{'csvfile'}}

sub csv_read {
    my $self = shift;
    my $header;
    my @lines = ();
    open my $fh, '<', $self->csv_file;
    while (my $line = <$fh>) {
        chomp $line;
        if (! defined $header) {
            $header = $line;
            next;
        }
        push @lines, $line;
    }
    close $fh;
    return ($header, @lines);
}

sub page_count {
    my $self = shift;
    my ($header, @lines) = $self->csv_read;
    my $page_count = int(scalar @lines / $self->page_size);
    print Dumper $page_count;
    return $page_count;
}

sub page_next {
    my ($self, $next_idx) = @_;
    my ($header, @lines) = $self->csv_read;
    my $page_size = $self->page_size;
    my $page = [splice @lines, $next_idx * $self->page_size, $page_size];
    return $page;
}

sub page_size {2}

sub process_result {
    my ($self, $result) = @_;
    print Dumper "result: $result";
}

__PACKAGE__->new->main;
exit;