#define LIB_FAR_PARAM

/* atoll function */
#include <stddef.h>
#include <stdlib.h>


#if defined(LIB_FAR_PARAM)
#  define ATOLL            _COM_atoll_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOLL          _COM_strtoll_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define ATOLL            atoll
#  define NEARFAR          __near
#  define STRTOLL          strtoll
#endif /* defined(LIB_FAR_PARAM) */


long long int ATOLL(const char NEARFAR *nptr)
{
	return(STRTOLL(nptr,(char NEARFAR* NEARFAR*) NULL,10));
}
