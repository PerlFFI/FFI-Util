package FFI::Util;

use strict;
use warnings;
use constant;
use Config (); # TODO: way to get dlext without loading this
use FFI::Raw 0.27;
use Scalar::Util qw( refaddr );
use Exporter::Tidy
  deref => do {
    our @types = qw( ptr str int uint short ushort char uchar float double int64 uint64 long ulong );
    [map { ("deref_$_\_get","deref_$_\_set") } (@types, qw( size_t time_t dev_t gid_t uid_t ))];
  },
  buffer => [qw( scalar_to_buffer buffer_to_scalar )],
  types => [qw( _size_t _time_t _dev_t _gid_t _uid_t )],
;

# ABSTRACT: Some useful pointer utilities when writing FFI modules
# VERSION

=head1 SYNOPSIS

 use FFI::Util;

=head1 DESCRIPTION

This module provides some useful memory manipulation that is either difficult
or impossible in pure Perl.  It was originally intended to be used by
L<Archive::Libarchive::FFI>, but it may be useful in other projects.

=cut

=head1 FUNCTIONS

=head2 locate_module_share_lib

 my $path = locate_module_share_lib();
 my $path = locate_module_share_lib($module_name, $module_filename);

Returns the path to the shared library for the current module, or the
module specified by C<$module_name> (example: Foo::Bar) 
C<$module_filename>(example /full/path/Foo/Bar.pm).

=cut

sub locate_module_share_lib (;$)
{
  my($module, $modlibname) = @_;
  ($module, $modlibname) = caller() unless defined $modlibname;
  my @modparts = split(/::/,$module);
  my $modfname = $modparts[-1];
  my $modpname = join('/',@modparts);
  my $c = @modparts;
  $modlibname =~ s,[\\/][^\\/]+$,, while $c--;    # Q&D basename
  my $file = "$modlibname/auto/$modpname/$modfname.$Config::Config{dlext}";
  unless(-e $file)
  {
    $modlibname =~ s,[\\/][^\\/]+$,,;
    $file = "$modlibname/arch/auto/$modpname/$modfname.$Config::Config{dlext}";
  }
  $file;
};

my $lib = locate_module_share_lib();

*_lookup_type = FFI::Raw->new( $lib, 'lookup_type', FFI::Raw::str, FFI::Raw::str )->coderef;

foreach my $type (qw( size_t time_t dev_t gid_t uid_t ))
{
  my $real_type = _lookup_type($type);
  if($real_type)
  {
    constant->import("_$type" => eval "FFI::Raw::$real_type\()");
  }
}

foreach my $type (our @types)
{
  my $code_type = eval qq{ FFI::Raw::$type };
  do {
    my $name = "deref_$type\_get";
    no strict 'refs';
    *{$name} = FFI::Raw->new( $lib, $name, $code_type, FFI::Raw::ptr )->coderef;
  };
  
  do {
    my $name = "deref_$type\_set";
    no strict 'refs';
    *{$name} = FFI::Raw->new( $lib, $name, FFI::Raw::void, FFI::Raw::ptr, $code_type )->coderef;
  };
  
  foreach my $otype (qw( size_t time_t dev_t gid_t uid_t ))
  {
    if(_lookup_type($otype) eq $type)
    {
      no strict 'refs';
      *{"deref_$otype\_get"} = \&{"deref_$type\_get"};
      *{"deref_$otype\_set"} = \&{"deref_$type\_set"};
    }
  }
}

=head2 scalar_to_buffer

 my($ptr, $size) = scalar_to_buffer $scalar;

Given a scalar string value, return a pointer to where the data is stored
and the size of the scalar in bytes.

=cut

sub scalar_to_buffer ($)
{
  (unpack('L!', pack 'P', $_[0]), do { use bytes; length $_[0] });
}

=head2 buffer_to_scalar

 my $scalar = buffer_to_scalar($ptr, $size);

Given a pointer to a memory location and a size, construct a new scalar
with the same content and size.

=cut

sub buffer_to_scalar ($$)
{
  unpack 'P'.$_[1], pack 'L!', defined $_[0] ? $_[0] : 0;
}

1;
