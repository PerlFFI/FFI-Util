/*
 *  provide types for size_t, time_t, dev_t, gid_t, uid_t
 */

#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>

#define is_signed(type) (((type)-1) < 0)

#define storage(type) \
  if(sizeof(type) == sizeof(short))   \
    return is_signed(type) ? "_short" : "_ushort"; \
  else if(sizeof(type) == sizeof(int)) \
    return is_signed(type) ? "_int" : "_uint"; \
  else if(sizeof(type) == sizeof(long)) \
    return is_signed(type) ? "_long" : "_ulong"; \
  else if(sizeof(type) == sizeof(int64_t)) \
    return is_signed(type) ? "_int64" : "_uint64";

const char *
lookup_type(const char *name)
{
  if(!strcmp(name, "size_t"))
  {
    storage(size_t);
  }
  if(!strcmp(name, "time_t"))
  {
    storage(time_t);
  }
  if(!strcmp(name, "dev_t"))
  {
    storage(dev_t);
  }
  if(!strcmp(name, "gid_t"))
  {
    storage(gid_t);
  }
  if(!strcmp(name, "uid_t"))
  {
    storage(uid_t);
  }
  return NULL;
}
