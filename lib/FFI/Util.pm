package FFI::Util;

use strict;
use warnings;
use constant;
use 5.008001;
use Config;
use FFI::Platypus;
use FFI::Platypus::Buffer ();
use Scalar::Util qw( refaddr );
use Exporter::Tidy
  deref => do {
    our @types = qw( ptr str int uint short ushort char uchar float double int64 uint64 long ulong );
    [map { ("deref_$_\_get","deref_$_\_set") } (@types, qw( size_t time_t dev_t gid_t uid_t ))];
  },
  buffer => [qw( scalar_to_buffer buffer_to_scalar )],
  types => [qw( _size_t _time_t _dev_t _gid_t _uid_t )],
  locate_module_share_lib => [qw( locate_module_share_lib )],
;

# ABSTRACT: Some useful pointer utilities when writing FFI modules
# VERSION

=head1 SYNOPSIS

 use FFI::Util;

=head1 DESCRIPTION

B<Note>: This module has largely been obsoleted by L<FFI::Platypus>, which
I recommend that you use instead of this module.  This module may be removed
from CPAN at a future date, but not before 31 January 2017.

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

sub locate_module_share_lib (;$$)
{
  require FFI::Platypus::ConfigData;
  my($module, $modlibname) = @_;
  ($module, $modlibname) = caller() unless defined $modlibname;
  my @modparts = split(/::/,$module);
  my $modfname = $modparts[-1];
  my $modpname = join('/',@modparts);
  my $c = @modparts;
  $modlibname =~ s,[\\/][^\\/]+$,, while $c--;    # Q&D basename
  foreach my $dlext (@{ FFI::Platypus::ConfigData->config('config_dlext') })
  {
    my $file = "$modlibname/auto/$modpname/$modfname.$dlext";
    unless(-e $file)
    {
      $modlibname =~ s,[\\/][^\\/]+$,,;
      $file = "$modlibname/arch/auto/$modpname/$modfname.$dlext";
    }
    return $file if -e $file;
  }
  ();
};

our $ffi = FFI::Platypus->new;
$ffi->package;
$ffi->attach( [lookup_type => '_lookup_type'] => ['string'] => 'string');

# nicked this from FFI/Raw.pm
sub _ffi_void ()     { ord 'v' }
sub _ffi_int ()      { ord 'i' }
sub _ffi_uint ()     { ord 'I' }
sub _ffi_short ()    { ord 'z' }
sub _ffi_ushort ()   { ord 'Z' }
sub _ffi_long ()     { ord 'l' }
sub _ffi_ulong ()    { ord 'L' }
sub _ffi_int64 ()    { ord 'x' }
sub _ffi_uint64 ()   { ord 'X' }
sub _ffi_char ()     { ord 'c' }
sub _ffi_uchar ()    { ord 'C' }
sub _ffi_float ()    { ord 'f' }
sub _ffi_double ()   { ord 'd' }
sub _ffi_str ()      { ord 's' }
sub _ffi_ptr ()      { ord 'p' }

foreach my $type (qw( size_t time_t dev_t gid_t uid_t ))
{
  my $real_type = _lookup_type($type);
  if($real_type)
  {
    constant->import("_$type" => eval "_ffi_$real_type\()");
  }
}

$ffi->type( void             => 'raw_void'   );
$ffi->type( string           => 'raw_str'    );
$ffi->type( int              => 'raw_int'    );
$ffi->type( 'unsigned int'   => 'raw_uint'   );
$ffi->type( short            => 'raw_short'  );
$ffi->type( 'unsigned short' => 'raw_ushort' );
$ffi->type( long             => 'raw_long'   );
$ffi->type( 'unsigned long'  => 'raw_ulong'  );
$ffi->type( 'uint64'         => 'raw_uint64' );
$ffi->type( 'sint64'         => 'raw_int64'  );
$ffi->type( 'signed char'    => 'raw_char'   );
$ffi->type( 'unsigned char'  => 'raw_uchar'  );
$ffi->type( 'float'          => 'raw_float'  );
$ffi->type( 'double'         => 'raw_double' );

$ffi->custom_type(raw_ptr => {
  perl_to_native => sub { ref($_[0]) ? ${$_[0]} : $_[0] },
  native_to_perl => sub { $_[0] },
});

for (qw( ptr str int uint short ushort long ulong char uchar float double int64 uint64 ))
{
  $ffi->attach( "deref_${_}_get" => ['raw_ptr']          => "raw_$_" => '$'  );
  $ffi->attach( "deref_${_}_set" => ['raw_ptr',"raw_$_"] => 'void'   => '$$' );
}

foreach my $type (our @types)
{
  my $code_type = eval qq{ _ffi_$type };
  foreach my $otype (qw( size_t time_t dev_t gid_t uid_t ))
  {
    if((_lookup_type($otype)||'') eq $type)
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

use constant _incantation => 
  $^O eq 'MSWin32' && $Config{archname} =~ /MSWin32-x64/
  ? 'Q'
  : 'L!';


sub scalar_to_buffer ($)
{
  (unpack(_incantation, pack 'P', $_[0]), do { use bytes; length $_[0] });
}

=head2 buffer_to_scalar

 my $scalar = buffer_to_scalar($ptr, $size);

Given a pointer to a memory location and a size, construct a new scalar
with the same content and size.

=cut

sub buffer_to_scalar ($$)
{
  unpack 'P'.$_[1], pack _incantation, defined $_[0] ? $_[0] : 0;
}

1;
