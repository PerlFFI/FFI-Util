use strict;
use warnings;
use Test::More tests => 1;
use FFI::Util qw( :types );

pass 'good';

diag '';
diag '';
diag "size_t = " . _size_t;
diag "time_t = " . _time_t;
diag "dev_t  = " . _dev_t;
diag "gid_t  = " . _gid_t;
diag "uid_t  = " . _uid_t;
diag '';
diag '';
