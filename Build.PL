#!/usr/bin/perl

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Tree::Make',
    license             => 'perl',
    dist_author         => 'Jozef Kutej <jkutej@cpan.org>',
    dist_version_from   => 'lib/Tree/Make.pm',
    requires => {
        'Class::Accessor::Fast' => 0,
        'File::Spec'            => 0,
        'File::Basename'        => 0,
        'IPC::Run'              => 0,
        'File::Slurp'           => 0,
    },
    build_requires => {
        'Test::More'  => 0,
    },
    script_files => [
        'script/treemake',
    ],
    
    add_to_cleanup      => [ 'Tree-Make-*' ],
    create_makefile_pl  => 'traditional',
    create_readme       => 1,
    sign                => 1,
);

$builder->create_build_script();
