


#include <stdlib.h>
#include <stddef.h>

#define LIB_FAR_PARAM

#if defined(LIB_FAR_PARAM)
#  define QSORT            _COM_qsort_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define QSORT            qsort
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

#define FALSE 0
#define TRUE 1


void QSORT(void NEARFAR *base, size_t nmemb, size_t size,
                 int (*compar)(const void NEARFAR *,
                                     const void NEARFAR *))
{
    size_t gap = nmemb;
    size_t i;
    size_t copycnt;
    char NEARFAR *p;
    char NEARFAR *q;
    char temp;
    unsigned char is_sort_finish = FALSE;

    while(gap > 1 || !is_sort_finish){
        if (gap > 1) {
            gap = (size_t)(((unsigned long)gap * 10) / 13);
            if ((gap == 9) || (gap == 10)) {
                gap = 11;
            } /* if */
        } /* if */

        is_sort_finish = TRUE;
        for (i=0; i<(nmemb-gap); ++i) {
            p = (char NEARFAR *)base + i*size;
            q = (char NEARFAR *)base + (i+gap)*size;
            if (compar((const void NEARFAR *)p, (const void NEARFAR *)q) > 0) {
                for (copycnt=0; copycnt<size; ++copycnt) {
                    temp = *p;
                    *p++ = *q;
                    *q++ = temp;
                } /* for */
                is_sort_finish = FALSE;
            } /* if */
        } /* for */
    } /* while */

}  /* QSORT */
