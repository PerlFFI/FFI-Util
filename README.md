# FFI::Util

Some useful pointer utilities when writing FFI modules

# SYNOPSIS

    use FFI::Util;

# DESCRIPTION

At the moment, this is a sort of proof of concept, and may not be
all that well planned or thought out.

# FUNCTIONS

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

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
