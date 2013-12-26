package FFI::Util;

use strict;
use warnings;
use constant;
use Config (); # TODO: way to get dlext without loading this
use FFI::Raw 0.18;
use FFI::Sweet;
use base qw( Exporter );
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

At the moment, this is a sort of proof of concept, and may not be
all that well planned or thought out.

=cut

ffi_lib do {
  my($module, $modlibname) = ('FFI::Util', __FILE__);
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
  \$file;
};

attach_function 'lookup_type', [ _str ], _str;

foreach my $type (qw( size_t time_t dev_t gid_t uid_t ))
{
  my $real_type = lookup_type($type);
  if($real_type)
  {
    constant->import("_$type" => eval "$real_type\()");
  }
}

foreach my $type (our @types)
{
  my $code_type = eval qq{ _$type };
  attach_function "deref_$type\_get", [ _ptr ], $code_type;
  attach_function "deref_$type\_set", [ _ptr, $code_type ], _void;
  
  foreach my $otype (qw( size_t time_t dev_t gid_t uid_t ))
  {
    if(lookup_type($otype) eq "_$type")
    {
      attach_function [ "deref_$type\_get", "deref_$otype\_get" ], [ _ptr ], $code_type;
      attach_function [ "deref_$type\_set", "deref_$otype\_set" ], [ _ptr, $code_type ], _void;
    }
  }
}

=head1 FUNCTIONS

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
