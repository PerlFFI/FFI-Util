#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

void
scalar_to_buffer(SV *sv, void **ptr, STRLEN *size)
{
  *ptr = SvPV(sv, *size);
}

void
buffer_to_scalar(SV *sv, void *ptr, STRLEN size)
{
  sv_setpvn(sv, ptr, size);
}

