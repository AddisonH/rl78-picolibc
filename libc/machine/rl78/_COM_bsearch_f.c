

#define LIB_FAR_PARAM

#include <stdlib.h>
#include <stddef.h>



#if defined(LIB_FAR_PARAM)
#  define BSEARCH          _COM_bsearch_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define BSEARCH          bsearch
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

void NEARFAR * BSEARCH(const void NEARFAR *key,
			     const void NEARFAR *base,
			     size_t nelem, size_t size,
			     int (*cmp)(const void NEARFAR *ck,
			                      const void NEARFAR *ce))
{
	size_t mid;
	size_t left = 0;
	size_t right = nelem - 1;
	int ret;

	if (nelem == 0) {
		return (void NEARFAR *)NULL;
	} /* if */

	while (1) {
		mid = left + (right-left)/2;
		if (!(ret = cmp(key,
		                (void NEARFAR *)((char NEARFAR *)base +
		                                                 mid * size))))
			return ((void NEARFAR *)((char NEARFAR *)base +
			                                         mid * size));
		if (ret > 0) {
			if (mid == right)  break;
			left = mid + 1;
		}
		else {
			if (mid == left)  break;
			right = mid - 1;
		}
	}
	return (void NEARFAR *)NULL;
}
