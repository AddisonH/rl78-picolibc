

#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdlib.h>
#undef atoff



#if defined(LIB_FAR_PARAM)
#  define ATOFF            _COM_atoff_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOF           _COM_strtof_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define ATOFF            atoff
#  define NEARFAR          __near
#  define STRTOF           strtof
#endif /* defined(LIB_FAR_PARAM) */

float ATOFF(const char NEARFAR *s)
{
	return STRTOF(s, (char NEARFAR * NEARFAR *)NULL);
}