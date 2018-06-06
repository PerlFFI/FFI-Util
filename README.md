# FFI::Util [![Build Status](https://secure.travis-ci.org/Perl5-FFI/FFI-Util.png)](http://travis-ci.org/Perl5-FFI/FFI-Util)

Some useful pointer utilities when writing FFI modules (Deprecated)

# SYNOPSIS

    use FFI::Util;

# DESCRIPTION

**Note**: This module has largely been obsoleted by [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus), which
I recommend that you use instead of this module.  This module may be removed
from CPAN at a future date, but not before 31 January 2017.

This module provides some useful memory manipulation that is either difficult
or impossible in pure Perl.  It was originally intended to be used by
[Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI), but it may be useful in other projects.

# FUNCTIONS

## locate\_module\_share\_lib

    my $path = locate_module_share_lib();
    my $path = locate_module_share_lib($module_name, $module_filename);

Returns the path to the shared library for the current module, or the
module specified by `$module_name` (example: Foo::Bar) 
`$module_filename`(example /full/path/Foo/Bar.pm).

## scalar\_to\_buffer

    my($ptr, $size) = scalar_to_buffer $scalar;

Given a scalar string value, return a pointer to where the data is stored
and the size of the scalar in bytes.

## buffer\_to\_scalar

    my $scalar = buffer_to_scalar($ptr, $size);

Given a pointer to a memory location and a size, construct a new scalar
with the same content and size.

## deref\_ptr\_get

    my $ptr2 = deref_ptr_get($ptr1);

equivalent to

    void *ptr1;
    void *ptr2;
    *ptr2 = *ptr1;

## deref\_ptr\_set

    deref_ptr_set($ptr1, $ptr2);

equivalent to

    void **ptr1;
    void *ptr2;
    *ptr1 = ptr2;

## deref\_str\_get

    my $string = deref_str_get($ptr);

equivalent to

    const char *string;
    const char **ptr;
    string = *ptr;

## deref\_str\_set

    deref_str_set($ptr, $string);

equivalent to

    const char **ptr;
    const char *string;
    *ptr = string;

## deref\_int\_get

    my $integer = deref_int_get($ptr);

equivalent to

    int *ptr;
    int integer;
    integer = *ptr;

## deref\_int\_set

    deref_int_set($ptr, $integer);

equivalent to

    int *ptr;
    int integer;
    *ptr = integer;

## deref\_uint\_get

    my $unsigned_integer = deref_uint_get($ptr);

equivalent to

    unsigned int unsigned_integer;
    unsigned int *ptr;
    unsigned_integer = *ptr;

## deref\_uint\_set

    deref_uint_set($ptr, $unsigned_integer);

equivalent to

    unsigned int *ptr;
    unsigned int unsigned_integer;
    *ptr = unsigned_integer;

## deref\_short\_get

    my $short_integer = deref_short_get($ptr);

equivalent to

    short short_integer;
    short *ptr;
    short_integer = *ptr;

## deref\_short\_set

    deref_short_set($ptr, $short_integer);

equivalent to

    short *ptr;
    short short_integer;
    *ptr = short_integer;

## deref\_ushort\_get

    my $unsigned_short_integer = deref_ushort_get($ptr);

equivalent to

    unsigned short unsigned_short_integer;
    unsigned short *ptr;
    unsigned unsigned_short_integer = *ptr;

## deref\_ushort\_set

    deref_ushort_set($ptr, $unsigned_short_integer);

equivalent to

    unsigned short *ptr;
    unsigned short unsigned_short_integer;
    *ptr = unsigned_short_integer;

## deref\_long\_get

    my $long_integer = deref_long_get($ptr);

equivalent to

    long long_integer;
    long *ptr;
    long_integer = *ptr;

## deref\_long\_set

    deref_long_set($ptr, $long_integer);

equivalent to

    long *ptr;
    long long_integer;
    *ptr = long_integer;

## deref\_ulong\_get

    my $unsigned_long_integer = deref_ulong_get($ptr);

equivalent to

    unsigned long unsigned_long_integer;
    unsigned long *ptr;
    unsigned unsigned_long_integer = *ptr;

## deref\_ulong\_set

    deref_ulong_set($ptr, $unsigned_long_integer);

equivalent to

    unsigned long *ptr;
    unsigned long unsigned_long_integer;
    *ptr = unsigned_long_integer;

## deref\_char\_get

    my $char_integer = deref_char_get($ptr);

equivalent to

    char char_integer;
    char *ptr;
    char_integer = *ptr;

## deref\_char\_set

    deref_char_set($ptr, $char_integer);

equivalent to

    char *ptr;
    char char_integer;
    *ptr = char_integer;

## deref\_uchar\_get

    my $unsigned_char_integer = deref_uchar_get($ptr);

equivalent to

    unsigned char unsigned char_integer;
    unsigned char *ptr;
    unsigned_char_integer = *ptr;

## deref\_uchar\_set

    deref_uchar_set($ptr, $unsigned_char_integer);

equivalent to

    unsigned char *ptr;
    unsigned char unsigned_char_integer;
    *ptr = unsigned_char_integer;

## deref\_float\_get

    my $single_float = deref_float_get($ptr);

equivalent to

    float single_float;
    float *ptr;
    single_float = *ptr;

## deref\_float\_set

    deref_float_set($ptr, $single_float);

equivalent to

    float *ptr;
    float single_float;
    *ptr = single_float;

## deref\_double\_get

    my $double_float = deref_double_get($ptr);

equivalent to

    double double_float;
    double *ptr;
    double_float = *ptr;

## deref\_double\_set

    deref_double_set($ptr, $double_float);

equivalent to

    double *ptr;
    double double_float;
    *ptr = double_float;

## deref\_int64\_get

    my $int64 = deref_int64_get($ptr);

equivalent to

    int64_t int64;
    int64_t *ptr;
    int64 = *ptr;

## deref\_int64\_set

    deref_int64_set($ptr, $int64);

equivalent to

    int64_t *ptr;
    int64_t int64;
    *ptr = int64;

## deref\_uint64\_get

    my $uint64 = deref_uint64_get($ptr);

equivalent to

    uint64_t uint64;
    uint64_t *ptr;
    uint64 = *ptr;

## deref\_uint64\_set

    deref_uint64_set($ptr, $uint64);

equivalent to

    uint64_t *ptr;
    uint64_t uint64;
    *ptr = uint64;

## deref\_dev\_t\_get

Alias for appropriate `derf_..._get` if dev\_t is provided by your compiler.

## deref\_dev\_t\_set

Alias for appropriate `derf_..._set` if dev\_t is provided by your compiler.

## deref\_gid\_t\_get

Alias for appropriate `derf_..._get` if gid\_t is provided by your compiler.

## deref\_gid\_t\_set

Alias for appropriate `derf_..._set` if gid\_t is provided by your compiler.

## deref\_size\_t\_get

Alias for appropriate `derf_..._get` if size\_t is provided by your compiler.

## deref\_size\_t\_set

Alias for appropriate `derf_..._set` if size\_t is provided by your compiler.

## deref\_time\_t\_get

Alias for appropriate `derf_..._get` if time\_t is provided by your compiler.

## deref\_time\_t\_set

Alias for appropriate `derf_..._set` if time\_t is provided by your compiler.

## deref\_uid\_t\_get

Alias for appropriate `derf_..._get` if uid\_t is provided by your compiler.

## deref\_uid\_t\_set

Alias for appropriate `derf_..._set` if uid\_t is provided by your compiler.

# SEE ALSO

- [Module::Build::FFI](https://metacpan.org/pod/Module::Build::FFI)
- [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
