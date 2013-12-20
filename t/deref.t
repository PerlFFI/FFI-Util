use strict;
use warnings;
use Test::More tests => 1;
use FFI::Util qw( deref_ptr_set deref_ptr_get );
use FFI::Raw;
use Config;

my $ptr = FFI::Raw::MemPtr->new($Config{ivsize});

deref_ptr_set $ptr, 42;
is deref_ptr_get($ptr), 42;
