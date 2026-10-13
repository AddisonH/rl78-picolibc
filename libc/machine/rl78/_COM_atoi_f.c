

#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#undef atoi



#if defined(LIB_FAR_PARAM)
#  define ATOI             _COM_atoi_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOL           _COM_strtol_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define ATOI             atoi
#  define NEARFAR          __near
#  define STRTOL           strtol
#endif /* defined(LIB_FAR_PARAM) */

int ATOI(const char NEARFAR *s)
{
	long val;
	val = STRTOL(s, (char NEARFAR * NEARFAR *)NULL, 10);
	if (val < INT_MIN) {
		errno = ERANGE;
		return INT_MIN;
	} else if (val > INT_MAX) {
		errno = ERANGE;
		return INT_MAX;
	}
	return (int)val;
}
