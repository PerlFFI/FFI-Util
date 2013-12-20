package FFI::Util::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );
use Carp qw( croak );
use File::Spec;

sub new
{
  my($class, %args) = @_;
  
  $args{c_source} = 'ffi';
  
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

  $self->cbuilder->link(
    module_name => $module_name,
    objects     => $objects,
    lib_file    => $spec->{lib_file},
    extra_linker_flags => $p->{extra_linker_flags} );

  return $spec->{lib_file};  
}

sub process_xs_files
{
  my $self = shift;
  return if $self->pureperl_only && $self->allow_pureperl;
  croak 'Can\'t build ffi files under --pureperl-only' if $self->pureperl_only;

  croak 'Can\'t determine module_name' unless $self->module_name;

  my $fake_xs = do {
    my @parts = split /::/, $self->module_name;
    $parts[-1] .= ".xs";
    File::Spec->catfile('lib', @parts);
  };

  # TODO: don't depend on this private method
  # from Module::Build::Base
  my $spec = $self->_infer_xs_spec($fake_xs);

  # File name, minus the suffix
  (my $file_base = $fake_xs) =~ s/\.[^.]+$//;
  
  # archdir
  File::Path::mkpath($spec->{archdir}, 0, oct(777)) unless -d $spec->{archdir};

  # .o -> .(a|bundle)
  $self->link_c($spec);
}

1;

