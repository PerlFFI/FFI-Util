#include <stdint.h>

/*

=head2 deref_ptr_get

 my $ptr2 = deref_ptr_get($ptr1);

equivalent to

 void *ptr1;
 void *ptr2;
 *ptr2 = *ptr1;

=cut

*/
void *deref_ptr_get(void **ptr)
{
  return *ptr;
}

/*

=head2 deref_ptr_set

 deref_ptr_set($ptr1, $ptr2);

equivalent to

 void **ptr1;
 void *ptr2;
 *ptr1 = ptr2;

=cut

*/

void deref_ptr_set(void **ptr, void *value)
{
  *ptr = value;
}

/*

=head2 deref_str_get

 my $string = deref_str_get($ptr);

equivalent to

 const char *string;
 const char **ptr;
 string = *ptr;

=cut

*/

const char *deref_str_get(const char **ptr)
{
  return *ptr;
}

/*

=head2 deref_str_set

 deref_str_set($ptr, $string);

equivalent to

 const char **ptr;
 const char *string;
 *ptr = string;

=cut

*/

void deref_str_set(const char **ptr, const char *value)
{
  *ptr = value;
}

/*

=head2 deref_int_get

 my $integer = deref_int_get($ptr);

equivalent to

 int *ptr;
 int integer;
 integer = *ptr;

=cut

*/

int deref_int_get(int *ptr)
{
  return *ptr;
}

/*

=head2 deref_int_set

 deref_int_set($ptr, $integer);

equivalent to

 int *ptr;
 int integer;
 *ptr = integer;

=cut

*/

void deref_int_set(int *ptr, int value)
{
  *ptr = value;
}

/*

=head2 deref_uint_get

 my $unsigned_integer = deref_uint_get($ptr);

equivalent to

 unsigned int unsigned_integer;
 unsigned int *ptr;
 unsigned_integer = *ptr;

=cut

*/

unsigned int deref_uint_get(unsigned int *ptr)
{
  return *ptr;
}

void deref_uint_set(unsigned int *ptr, unsigned int value)
{
  *ptr = value;
}

short deref_short_get(short *ptr)
{
  return *ptr;
}

void deref_short_set(short *ptr, short value)
{
  *ptr = value;
}

unsigned short deref_ushort_get(unsigned short *ptr)
{
  return *ptr;
}

void deref_ushort_set(unsigned short *ptr, unsigned short value)
{
  *ptr = value;
}

long deref_long_get(long *ptr)
{
  return *ptr;
}

void deref_long_set(long *ptr, long value)
{
  *ptr = value;
}

unsigned long deref_ulong_get(unsigned long *ptr)
{
  return *ptr;
}

void deref_ulong_set(unsigned long *ptr, unsigned long value)
{
  *ptr = value;
}

char deref_char_get(char *ptr)
{
  return *ptr;
}

void deref_char_set(char *ptr, char value)
{
  *ptr = value;
}

unsigned char deref_uchar_get(unsigned char *ptr)
{
  return *ptr;
}

void deref_uchar_set(unsigned char *ptr, unsigned char value)
{
  *ptr = value;
}

float deref_float_get(float *ptr)
{
  return *ptr;
}

void deref_float_set(float *ptr, float value)
{
  *ptr = value;
}

double deref_double_get(double *ptr)
{
  return *ptr;
}

void deref_double_set(float *ptr, double value)
{
  *ptr = value;
}

int64_t deref_int64_get(int64_t *ptr)
{
  return *ptr;
}

void deref_int64_set(int64_t *ptr, int64_t value)
{
  *ptr = value;
}

uint64_t deref_uint64_get(uint64_t *ptr)
{
  return *ptr;
}

void deref_uint64_set(uint64_t *ptr, uint64_t value)
{
  *ptr = value;
}

