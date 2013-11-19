package FFI::AgainstType;

use strict;
use warnings;
use FFI::Raw ();
use FFI::Sweet qw( ffi_lib attach_function :types );
use base qw( Exporter );

# ABSTRACT: The opposite of type casting
# VERSION

ffi_lib do {
  my($module, $modlibname) = ('FFI::AgainstType', __FILE__);
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

sub _int64 ()  { FFI::Raw::int64()  }
sub _uint64 () { FFI::Raw::uint64() }

attach_function "dereference_to_ptr",    [ _ptr ], _ptr;
attach_function "dereference_to_int",    [ _ptr ], _int;
attach_function "dereference_to_uint",   [ _ptr ], _uint;
attach_function "dereference_to_short",  [ _ptr ], _short;
attach_function "dereference_to_ushort", [ _ptr ], _ushort;
attach_function "dereference_to_char",   [ _ptr ], _char;
attach_function "dereference_to_uchar",  [ _ptr ], _uchar;
attach_function "dereference_to_float",  [ _ptr ], _float;
attach_function "dereference_to_double", [ _ptr ], _double;
attach_function "dereference_to_int64",  [ _ptr ], _int64;
attach_function "dereference_to_uint64", [ _ptr ], _uint64;

our @EXPORT_OK = map { "dereference_to_$_" } qw( ptr int uint short ushort char uchar float double int64 uint64 );

1;
