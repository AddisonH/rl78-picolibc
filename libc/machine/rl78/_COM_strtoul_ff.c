#define LIB_FAR_PARAM

#include <errno.h>
#include <limits.h>
#include <ctype.h>
#include <stdlib.h>

#if defined(LIB_FAR_PARAM)
#  define STRTOUL          _COM_strtoul_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOUL          strtoul
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */

unsigned long STRTOUL(const char NEARFAR * __restrict s,
                            char NEARFAR * NEARFAR * __restrict endptr, int base)
{
	unsigned int n;
	unsigned long x = 0L;
	int minus = 0;
	char NEARFAR *p = (char NEARFAR *)s;
	_Bool over = 0;

	if (base < 0 || base > 36) {
		/* base �`�F�b�N (0 - 36) */
		goto STRTOUL_END;
	}

	for (; isspace(*p); p++);

	if ((*p == '-') || (*p == '+')) {

		if (*p == '-')
			minus = 1;
		p++;
		if (!isalnum(*p))
			goto STRTOUL_END;
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
			goto STRTOUL_END;
	} else {
		goto STRTOUL_END;
	}

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
			if (x <= (ULONG_MAX - n) / (unsigned)base) {
				x = x * (unsigned)base + n;
			} else {
				over = 1;
			}
		}
	}
	if (over) {
		x = ULONG_MAX;
		errno = ERANGE;
	}

	STRTOUL_END:
	if (endptr)
		*endptr = (char NEARFAR *)s;
	if (minus && !over)
		x = -(x);
	return x;
}
