package FFI::Util;

use strict;
use warnings;
use FFI::Raw 0.18;
use FFI::Sweet;
use base qw( Exporter );
use Scalar::Util qw( refaddr );

# ABSTRACT: Some useful pointer utilities when writing FFI modules
# VERSION

our @EXPORT_OK = map { "deref_to_$_" } qw( ptr int uint short ushort char uchar float double int64 uint64 );
push @EXPORT_OK, qw( scalar_to_buffer buffer_to_scalar );

ffi_lib do {
  my($module, $modlibname) = ('FFI::Util', __FILE__);
  my @modparts = split(/::/,$module);
  my $modfname = $modparts[-1];
  my $modpname = join('/',@modparts);
  my $c = @modparts;
  $modlibname =~ s,[\\/][^\\/]+$,, while $c--;    # Q&D basename
  my $file = "$modlibname/auto/$modpname/$modfname.so";
  unless(-e $file)
  {
    $modlibname =~ s,[\\/][^\\/]+$,,;
    $file = "$modlibname/arch/auto/$modpname/$modfname.so"
  }
  \$file;
};

attach_function "deref_to_ptr",    [ _ptr ], _ptr;
attach_function "deref_to_int",    [ _ptr ], _int;
attach_function "deref_to_uint",   [ _ptr ], _uint;
attach_function "deref_to_short",  [ _ptr ], _short;
attach_function "deref_to_ushort", [ _ptr ], _ushort;
attach_function "deref_to_long",   [ _ptr ], _long;
attach_function "deref_to_ulong",  [ _ptr ], _ulong;
attach_function "deref_to_char",   [ _ptr ], _char;
attach_function "deref_to_uchar",  [ _ptr ], _uchar;
attach_function "deref_to_float",  [ _ptr ], _float;
attach_function "deref_to_double", [ _ptr ], _double;
attach_function "deref_to_int64",  [ _ptr ], _int64;
attach_function "deref_to_uint64", [ _ptr ], _uint64;

attach_function "scalar_to_buffer", [ _ptr, _ptr, _ptr ], _void, sub
{
  # 0 cb 1 scalar
  my $ptr  = FFI::Raw::MemPtr->new_from_ptr(0);
  my $size = FFI::Raw::MemPtr->new(8); # FIXME: STRLEN
  my $ref = \$_[1];
  $_[0]->(refaddr($ref), $ptr, $size);
  (deref_to_ptr($$ptr), deref_to_uint64($$size));
};

attach_function "buffer_to_scalar", [ _ptr, _ptr, _ptr ], _void, sub
{
  my($cb, $ptr, $size) = @_;
  my $sv = '\x00' x $size;
  $cb->(\$sv, $ptr, $size);
  $sv;
};

1;
