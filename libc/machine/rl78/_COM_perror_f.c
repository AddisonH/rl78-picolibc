


#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>



#if defined(LIB_FAR_PARAM)
#  define PERROR           _COM_perror_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define PERROR           perror
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */


void PERROR( const char NEARFAR *str )
{
    const char __far *message;

    if (str != NULL) {
        while (*str != '\0') {
            putchar(*str);
            ++str;
        } /* while */
        putchar(':');
        putchar(' ');
    } /* if */

    message = strerror(errno);

    while (*message != '\0') {
        putchar(*message);
        ++message;
    } /* while */

    putchar('\n');

    return;
}  /* perror */
