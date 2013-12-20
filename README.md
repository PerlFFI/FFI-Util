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

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
