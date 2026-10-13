

#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdlib.h>
#undef atof


#if defined(LIB_FAR_PARAM)
#  define ATOF             _COM_atof_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOD           _COM_strtod_ff
#  define STRTOF           _COM_strtof_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define ATOF             atof
#  define NEARFAR          __near
#  define STRTOD           strtod
#  define STRTOF           strtof
#endif /* defined(LIB_FAR_PARAM) */

double ATOF(const char NEARFAR *s)
{
#if defined(__RL78_64BIT_DOUBLES__)
	return STRTOD(s, (char NEARFAR * NEARFAR *)NULL);

#else /* !defined(__RL78_64BIT_DOUBLES__) */
	return STRTOF(s, (char NEARFAR * NEARFAR *)NULL);

#endif /* defined(__RL78_64BIT_DOUBLES__) */
}
