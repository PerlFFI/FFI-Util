package Module::Build::FFI;

use strict;
use warnings;
use base qw( Module::Build );
use Config;
use Carp qw( croak );
use File::Spec;
use File::Temp qw( tempdir );
use File::Copy qw( copy cp );
use File::Basename qw( basename );
use File::ShareDir qw( dist_dir );
use Text::ParseWords qw(shellwords);

# ABSTRACT: Build Perl extensions if C with FFI.
# VERSION

=head1 SYNOPSIS

raw Build.PL:

 use Module::Build::FFI 0.04;
 Module::Build::FFI->new(
   module_name => 'Foo::Bar',
   ...
 )->create_build_script;

Dist::Zilla:

 [ModuleBuild]
 mb_class      = Module::Build::FFI
 
 [Prereqs / ConfigureRequires]
 Module::Build::FFI = 0.03

Put your .c and .h files in ffi (ffi/example.c):

 #include <ffi_util.h>
 #include <stdio.h>
 
 FFI_UTIL_EXPORT void print_hello(void)
 {
   printf("hello world\n");
 }

Attach it in your main module:

 package Foo::Bar;
 
 use FFI::Raw;
 use FFI::Util qw( locate_module_share_lib );
 
 my $lib = locate_module_share_lib();

 *print_hello = FFI::Raw->new($lib, 'hello_world', FFI::Raw::void)->coderef; 

Use it elsewhere:

 use Foo::Bar;
 Foo::Bar::hello_world();

=head1 DESCRIPTION

Module::Build variant for writing Perl extensions in C with FFI.

=head1 MACROS

If you include the header file C<ffi_util.h> you can use these macros.
The header file was first included with version L<FFI::Util> / 
L<Module::Build::FFI> 0.04, so you should be sure to make that a 
prerequisite in either your C<Build.PL> or C<dist.ini> (or both).

=over 4

=item FFI_UTIL_VERSION

This is the L<FFI::Util> version number multiplied by 100 (so it should be
4 for 0.04 and 101 for 1.01).

=item FFI_UTIL_EXPORT

The appropriate attribute needed to export functions from shared libraries
/ DLLs.  For now this is only necessary on Windows when using Microsoft
Visual C++, but it may be necessary elsewhere in the future.

=back

=cut

sub new
{
  my($class, %args) = @_;
  
  $args{c_source} ||= 'ffi';
  
  my $dir = eval { File::Spec->catdir(dist_dir('FFI-Util'), 'include') };
  unless($@)
  {
    if(defined $args{include_dirs} && !ref $args{include_dirs})
    {
      $args{include_dirs} = [ $args{include_dirs} ];
    }
    elsif(!defined $args{include_dirs})
    {
      $args{include_dirs} = [];
    }  
    push @{$args{include_dirs}}, $dir;
  }
  
  $class->SUPER::new(%args);
}

sub link_c
{
  my ($self, $spec) = @_;
  my $p = $self->{properties}; # For convenience

  $self->add_to_cleanup($spec->{lib_file});

  my $objects = $p->{objects} || [];

  return $spec->{lib_file}
    if $self->up_to_date($objects, $spec->{lib_file});

  my $module_name = $spec->{module_name} || $self->module_name;

  if($^O eq 'MSWin32')
  {
    my @cmd;
    if($Config{cc} !~ /cl(\.exe)?$/) # MSWin32 + GCC
    {
      my $lddlflags = $Config{lddlflags};
      $lddlflags =~ s{\\}{/}g;
      @cmd = ($Config{cc}, shellwords($lddlflags), -o => $spec->{lib_file}, "-Wl,--export-all-symbols", @$objects);
    }
    else                             # MSWin32 + Visual C++
    {
      @cmd = ($Config{cc}, @$objects, "/link", "/dll", "/out:" . $spec->{lib_file});
    }

    print "@cmd\n";
    system @cmd;
    die "error in link" if $?;
  }
  else
  {
    $self->cbuilder->link(
      module_name => $module_name,
      objects     => $objects,
      lib_file    => $spec->{lib_file},
      extra_linker_flags => $p->{extra_linker_flags},
    );
  };

  return $spec->{lib_file};  
}

sub process_xs_files
{
  my $self = shift;
  return if $self->pureperl_only && $self->allow_pureperl;
  croak 'Can\'t build ffi files under --pureperl-only' if $self->pureperl_only;

  croak 'Can\'t determine module_name' unless $self->module_name;

  my $spec = { module_name => $self->module_name };
  my $cf = $self->{config};

  my($fake_xs, $file_base) = do {
    my @parts = split /::/, $self->module_name;
    my @parts_xs   = @parts;
    
    $spec->{base_name} = $parts[-1];

    $spec->{archdir} = File::Spec->catdir($self->blib, 'arch', 'auto', @parts);
    
    require DynaLoader;
    my $modfname = defined &DynaLoader::mod2fname
    ? DynaLoader::mod2fname(['lib', @parts])
    : $parts[-1];

    $spec->{lib_file} = File::Spec->catfile($spec->{archdir}, "$modfname.".$cf->get('dlext'));
    
    $parts_xs[-1] .= ".xs";
    (
      File::Spec->catfile('lib', @parts_xs),
      File::Spec->catfile('lib', @parts),
    );
  };

  #my $spec = $self->_infer_xs_spec($fake_xs);

  # archdir
  File::Path::mkpath($spec->{archdir}, 0, oct(777)) unless -d $spec->{archdir};

  # .o -> .(a|bundle)
  $self->link_c($spec);
}

1;

=head1 SEE ALSO

=over 4

=item L<FFI::Util>

=item L<FFI::Raw>

=item L<Module::Build>

=back

=cut
