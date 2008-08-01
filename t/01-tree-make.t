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
	my $tree_make = Tree::Make->new(
		'base_folder' => File::Spec->catdir($Bin, 'tree-01'),
	);
	
	isa_ok($tree_make, 'Tree::Make');
	eq_or_diff(
		[ sort map { s/.+tree-01/base_folder/; $_ } $tree_make->all_makefiles ],
		[
			'base_folder/Folder/SubFolder/Makefile',
			'base_folder/Folder2/Subfolder/SubSubfolder/Makefile',
			'base_folder/Folder2/Subfolder2/Makefile',
		],
		'find all Makefile files',
	);
	
	return 0;
}

