#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
#use Test::More tests => 10;
use Test::Differences;
use Test::Exception;

use FindBin qw($Bin);
use File::Spec;
use lib "$Bin/lib";

BEGIN {
    use_ok ( 'Tree::Make' ) or exit;
}

exit main();

sub main {
	my @makefile_folders = (
		File::Spec->catdir($Bin, 'tree-01', 'Folder',  'SubFolder'),
		File::Spec->catdir($Bin, 'tree-01', 'Folder2', 'Subfolder',  'SubSubfolder'),
		File::Spec->catdir($Bin, 'tree-01', 'Folder2', 'Subfolder2'),
	);

	my $tree_make = Tree::Make->new(
		'base_folder' => File::Spec->catdir($Bin, 'tree-01'),
	);
	
	isa_ok($tree_make, 'Tree::Make');
	eq_or_diff(
		[ sort $tree_make->all_makefiles ],
		[ sort map { File::Spec->catfile($_, 'Makefile') } @makefile_folders ],
		'find all Makefile files',
	);
	
	# run all Makefile files that touch a file and saves output
	$tree_make->process_all_makefiles;
	
	my @expected_files_created = sort map {
		File::Spec->catfile($_, 'all-run'),
	} @makefile_folders;
	
	# check if the files were created
	eq_or_diff(
		[ map { -f $_ ? $_ : '' } @expected_files_created ],
		[ @expected_files_created ],
		'all Makefiles executed',
	);

	# cleanup files form previous run
	$tree_make->process_all_makefiles('clean');
	
	# check if the files were cleaned
	eq_or_diff(
		[ map { -f $_ ? $_ : '' } @expected_files_created ],
		[ map { '' } @expected_files_created ],
		'all Makefiles clean executed',
	);

	return 0;
}

