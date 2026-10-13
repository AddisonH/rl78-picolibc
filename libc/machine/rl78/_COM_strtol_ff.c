#define LIB_FAR_PARAM

#include <errno.h>
#include <limits.h>
#include <ctype.h>
#include <stdlib.h>

#if defined(LIB_FAR_PARAM)
#  define STRTOL           _COM_strtol_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOL           strtol
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

long STRTOL(const char NEARFAR * __restrict s,
                  char NEARFAR * NEARFAR * __restrict endptr, int base)
{
	unsigned int n;
	long x = 0L;
	int minus = 0;
	char NEARFAR *p = (char NEARFAR *)s;
	unsigned long max;
	_Bool over = 0;

	if (base < 0 || base > 36) {
		goto STRTOL_END;
	}

	for (; isspace(*p); p++);

	if ((*p == '-') || (*p == '+')) {
		if (*p == '-')
			minus = 1;
		p++;
		if (!isalnum(*p))
			goto STRTOL_END;
	}
	if (*p == '0') {
		if (*(p+1) == 'x' || *(p+1) == 'X') {
			if ((!base) || (base == 16)) {
				base = 16;
				p += 2;
			}
		} else {
			if (!base)
				base = 8;
		}
	}
	if (!base)
		base = 10;


	if (isalnum(*p)) {
		if (isdigit(*p)) {
			n = *p - '0';
		} else if (isupper(*p)) {
			n = *p - 'A' + 10;
		} else {
			n = *p - 'a' + 10;
		}
		if (n >= base)
			goto STRTOL_END;
	} else {
		goto STRTOL_END;
	}

	max = minus ? (unsigned long)LONG_MAX + 1 : LONG_MAX;

	for (s = p; isalnum(*s); s++) {
		if (isdigit(*s)) {
			n = *s - '0';
		} else if (isupper(*s)) {
			n = *s - 'A' + 10;
		} else {
			n = *s - 'a' + 10;
		}
		if (n >= base)
			break;
		if (!over) {
			if (x <= (max - n) / (unsigned)base) {
				x = x * (unsigned)base + n;
			} else {
				over = 1;
			}
		}
	}
	if (over) {
		if (minus) {
			minus = 0;
			x = LONG_MIN;
		} else {
			x = LONG_MAX;
		}
		errno = ERANGE;
	}

	STRTOL_END:
	if (endptr)
		*endptr = (char NEARFAR *)s;
	if (minus)
		x = -(x);
	return x;
}
