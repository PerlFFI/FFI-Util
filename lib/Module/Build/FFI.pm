package Module::Build::FFI;

use strict;
use warnings;
use base qw( Module::Build );
use Carp qw( croak );
use File::Spec;
use File::Temp qw( tempdir );
use File::Copy qw( copy cp );
use File::Basename qw( basename );

# ABSTRACT: Build Perl extensions if C with FFI.

=head1 SYNOPSIS

raw Build.PL:

 use Module::Build::FFI;
 Module::Build::FFI->new(
   module_name => 'Foo::Bar',
   ...
 )->create_build_script;

Dist::Zilla:

 [ModuleBuild]
 mb_class      = Module::Build::FFI

Put your .c and .h files in ffi (ffi/example.c):

 #include <stdio.h>
 
 void print_hello(void)
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

=cut

sub new
{
  my($class, %args) = @_;
  
  $args{c_source} ||= 'ffi';
  $args{requires}{'Alien::o2dll'} = '0' if $^O eq 'MSWin32';
  
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
    require Alien::o2dll;
    my $dir = tempdir( CLEANUP => 1 );
    
    foreach my $object (@$objects)
    {
      copy($object, File::Spec->catfile($dir, basename $object)) || die "unable to copy $!";
    }
    
    my $save = Win32::GetCwd();
    chdir $dir;
    Alien::o2dll::o2dll( -o => basename($spec->{lib_file}), map { basename $_ } @$objects );
    
    opendir my $dh, '.';
    my($tmp_dll_name) = grep /\.dll$/, readdir $dh;
    closedir  $dh;
    
    chdir $save;
    
    cp(File::Spec->catfile($dir, $tmp_dll_name), $spec->{lib_file}) || die "unable to copy $!";
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

