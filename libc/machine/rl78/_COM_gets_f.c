


#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdio.h>



#if defined(LIB_FAR_PARAM)
#  define GETS             _COM_gets_f
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define GETS             gets
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

char NEARFAR * GETS( char NEARFAR *buffer )
{
    int  i = 0;
    int  c;

    while ( ( c = getchar() ) != '\n' ) {
        if ( c == EOF ) {
            if ( i == 0 )
                return ( char * )NULL;
            else
                break;
        } else
            buffer[i++] = c;
    }
    buffer[i] = '\0';
    return  buffer;
}
