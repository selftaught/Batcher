#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Batcher;
use Cwd qw();
use Data::Dumper;
use DateTime;
use File::Spec::Functions 'catfile';
use Getopt::Long;
use Pod::Usage qw(pod2usage);
use Test::Exception;
use Test::Batcher;
use Test::MockModule;
use Test::More;
use Time::HiRes qw(usleep gettimeofday time);


my $forks_exact = undef;
my $forks_max = undef;
my $forks_min = 1;
my $iters = 5; # just runs the same iteration N (2) number of times
my $batch_count = 30;
my $batch_size = 1; # 2 items to process in each batch
my $batch_next = [('https://dillan.io') x $batch_size];
my $help = 0;
my $man = 0;
my $output = undef;
my $save = 0;

GetOptions(
    'f|forks=i' => \$forks_exact,
    'm|forks-min=i' => \$forks_min,
    'M|forks-max=i' => \$forks_max,
    'i|iters=i' => \$iters,
    'c|batch-count=i' => \$batch_count,
    's|batch-size=i' => \$batch_size,
    'S|save|?' => \$save,
    'w|write=s' => \$output,
    'help|?' => \$help,
    'man|?' => \$man,
) or pod2usage(2);

pod2usage(1) if $help;

if (!$forks_exact && !$forks_max) {
    die "You must pass either --forks=num or --forks-max=num!\n";
} elsif ($forks_exact && $forks_max) {
    die "You must pass only one of (-f),--forks=num or (-M),--forks-max=num but not both!\n";
}

my $dt = DateTime->now(time_zone => 'local');
my $auto_fork_info = ($forks_exact ? "forks-$forks_exact" : "forks-${forks_min}to${forks_max}");
my $auto_filename =
    sprintf 'batcher_perf_%02d%02d%04d_%d%d%d_%s_batches-%d_batchsize-%d.csv',
        $dt->month, $dt->day, $dt->year, $dt->hour, $dt->minute, $dt->second, $auto_fork_info, $batch_count, $batch_size;

if ($save && !defined $output) {
    $output = catfile(Cwd::cwd(), $auto_filename);
}

say "forks_max: " . ($forks_max // '(undef)');
say "forks_min: $forks_min";
say "forks_exact: " . ($forks_exact // '(undef)');
say "iterations: $iters";
say "batches: $batch_count";
say "batch_size: $batch_size";
say "output: $output";
say "save: $save";
say "write: $output";

my $io_micro_secs = 1000 * 5; # 50ms
my $io_ms = $io_micro_secs / 1000;
my $mock = Test::MockModule->new('Test::Batcher');

$mock->mock('batch_result', sub {usleep $io_micro_secs});
$mock->mock('logging', sub {0});

my $fh = *STDOUT;

if ($output) {
    open $fh, '>', $output or die "Couldn't open file $output: !$\n";
}
say $fh "io_ms_delay,forks,batch_count,batch_size,runtime,unix_time";
for (my $i = ($forks_exact ? $forks_exact : $forks_min); $i <= ($forks_exact ? $forks_exact : $forks_max);) {
    for (my $j = 0; $j < $iters; $j++) {
        my $forks = $i;
        my $batcher = Test::Batcher->new({
            batch_count => $batch_count,
            batch_next => $batch_next,
            batch_size => $batch_size,
            forks => $forks,
        });
        my $start = gettimeofday;
        $batcher->run;
        my $stop = gettimeofday;
        my $elapsed = $stop - $start;
        say $fh sprintf "%s,%i,%i,%i,%.04f,%.04f", "${io_ms}ms",$forks,$batch_count,$batch_size,$elapsed,time;
    }
    last if $forks_exact;
    if ($i >= 10) {
        $i += 5;
    } else {
        $i++;
    }
}
close $fh;

__END__

=head1 NAME

perf.pl - batcher performance profiler that outputs data points in csv format

=head1 SYNOPSIS

./perf.pl [options]

=head1 OPTIONS

=over 4

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-b, --batches=num>

Set the number of batches

=item B<-f, --forks=num>

Set the number of forks to profile

=item B<-i, --iters=num>

The number of iterations to run for each fork count profiled.

=item B<-m, --min-forks=num>

The minimum number of forks to run (default: 1)

=item B<-M, --max-forks=num>

The maximum number of forks to run (default: 100)

=item B<-o, --output=path>

CSV file output path (default: .) Passing a directory path will result in an auto-generated file name.

=item B<-s, --batch-size=num>

Set the number of items in a batch.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut

