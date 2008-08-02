package Tree::Make;

=head1 NAME

Tree::Make - find or execute all Makefile-s in a folder structure

=head1 SYNOPSIS

	my $tree_make = Tree::Make->new(
		'base_folder' => '/usr/src/lot-of-projects/',
	);
	
    my @makefile_files = $tree_make->all_makefiles;

=head1 DESCRIPTION

=cut

use warnings;
use strict;

our $VERSION = '0.01';

use FindBin '$Bin';
use File::Spec;
use File::Basename 'dirname';
use IPC::Run 'run';
use File::Slurp 'write_file';

use base 'Class::Accessor::Fast';


=head1 PROPERTIES

base_folder - default is current folder where the script is executed.

=cut

__PACKAGE__->mk_accessors(qw{
    base_folder
});

=head1 METHODS

=head2 new()

Object constructor.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new({
        # defaults
        'base_folder' => $Bin,
        
        # settings
        @_,
    });
    
    return $self;
}


=head2 all_makefiles($folder_name)

Method returns array of paths to all makefiles that are in $folder_name.
If not set the C<< $self->base_folder >> is used.

=cut

sub all_makefiles {
    my $self        = shift;
    my $folder_name = shift;
    
    $folder_name = $self->base_folder
        if not defined $folder_name;
    
    my @sub_folders;
    
    # walk through folder and look for Makefile and sub folders
    opendir(my $folder_fh, $folder_name);
    while (my $filename = readdir($folder_fh)) {
        # skip hidden files
        next if substr($filename, 0, 1) eq '.';
        
        my $filename_with_path = File::Spec->catfile($folder_name, $filename);
        
        # return path to Makefile if found
        return $filename_with_path
            if $filename eq 'Makefile';
        
        # store folder for future use
        push @sub_folders, $filename_with_path
            if (-d $filename_with_path);
    }
    closedir($folder_fh);
    
    # call all_makefiles for all subfolders if no makefile found in current folder
    my @makefiles;
    foreach my $subfolder_name (@sub_folders) {
        push @makefiles, $self->all_makefiles($subfolder_name);
    }
    
    return @makefiles;
}


=head2 process_all_makefiles(@make_args)

Loop thorugh all F<Makefile>-s and execute C<< $self->run_make(@make_args) >>.

=cut

sub process_all_makefiles {
    my $self = shift;
    my @make_args = @_;
    
    # loop through all makefiles
    foreach my $makefile ($self->all_makefiles) {
        $self->run_make($makefile, @make_args);
    }
}


=head2 run_make($makefile, @make_args)

Change to folder where C<$makefile> is located and runs
`make @make_args` in it. The stderr and stdout goest to
F<Makefile.output>. If the make exit value is non zero writes
exit value to F<failure> file.

=cut

sub run_make {
    my $self      = shift;
    my $makefile  = shift;
    my @make_args = @_;
    
    my $makefile_folder = dirname($makefile);
    chdir($makefile_folder);
    
    my $makefile_output_filename = 'Makefile.output';
    open my $makefile_output_fh, '>', $makefile_output_filename
        or die 'failed to write to '.$makefile_output_filename.' - '.$!;
    
    # run make and note down failure or success
    if (run
            [ 'make', @make_args ],
            \undef,
            $makefile_output_fh,
            $makefile_output_fh,
        ) {
        unlink('failed');
    }
    else {
        write_file('failed', $?);
    }
    
    close($makefile_output_fh);
}

1;


__END__

=head1 AUTHOR

Jozef Kutej

=cut
