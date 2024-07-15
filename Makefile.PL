#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Batcher',
    AUTHOR       => 'Dillan Hildebrand',
    VERSION_FROM => 'lib/Batcher.pm',
    LICENSE      => 'MIT',
    PREREQ_PM    => {
        'Data::Dumper' => '2.154',
        'Test::Exception' => '0.43',
    },
    META_MERGE => {
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/selftaught/Batcher.git',
                web  => 'https://github.com/selftaught/Batcher',
            }
        },
    }
);