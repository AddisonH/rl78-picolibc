

#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdlib.h>
#undef atol



#if defined(LIB_FAR_PARAM)
#  define ATOL             _COM_atol_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOL           _COM_strtol_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define ATOL             atol
#  define NEARFAR          __near
#  define STRTOL           strtol
#endif /* defined(LIB_FAR_PARAM) */

long ATOL(const char NEARFAR *s)
{
	return STRTOL(s, (char NEARFAR * NEARFAR *)NULL, 10);
}
