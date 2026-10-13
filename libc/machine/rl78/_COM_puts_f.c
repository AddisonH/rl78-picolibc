


#define LIB_FAR_PARAM

#include <stdio.h>

#if defined(LIB_FAR_PARAM)
#  define PUTS             _COM_puts_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define PUTS             puts
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

int PUTS( const char NEARFAR *str )
{
    int  c;

    while (( c = *str++ )) {
        if(  putchar( c ) == EOF )
            return  EOF;
    }
    if (  putchar( '\n' ) == EOF )
        return  EOF;
    else
        return  0;
}
