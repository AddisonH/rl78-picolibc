#define LIB_FAR_PARAM

#include <errno.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>
#include <float.h>

#define SGL_INFEXP 0xff

static int _REL_isinfinity(float d);

#if defined(LIB_FAR_PARAM)
#  define STRTOF           _COM_strtof_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOF           strtof
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */


float STRTOF(const char NEARFAR * __restrict s, char NEARFAR * NEARFAR * __restrict endptr)
{
	float d, e;
	float base;
	int exp = 0;
	char sign = '+';
	char esign = '+';
	const char NEARFAR *p = s;
	const char NEARFAR *tp;
	char seen = 0;

	d = e = 0.0F;

	for (; isspace(*p); p++);

	if ((*p == '-') || (*p == '+')) {
		sign = *p++;
	}
	if( *p == '.' ){
		s = p;
	}
	else if (*p == 'n' || *p == 'N')
	{	/* match "nan" */
		tp = p;
		p++;
		if (*p != 'a' && *p != 'A')
			p = tp;
		else
		{	/* seen "na" */
			p++;
			if (*p != 'n' && *p != 'N')
				p = tp;
			else if (*(++p) != '(')
			{	/* got "nan" not "nan(n-char-sequence)", quit */
				s = p;
				seen = 1;
				d = NAN;
				goto STRTOD_END;
			}
			else
			{	/* parse (n-char-sequence) */
				seen = 1;
				tp = p;
				for (; isalnum(*(++p)) || *p == '_'; )
					;
				if (*p != ')') {
					s = tp;
				}
				else
				{	/* got it, replace with "nan" */
					s = ++p;
				}
				d = NAN;
				goto STRTOD_END;
			}
		}
	}
	else if (*p == 'i' || *p == 'I')
	{	/* match "inf" */
		tp = p;
		p++;
		if (*p != 'n' && *p != 'N')
			p = tp;
		else
		{	/* seen "in" */
			p++;
			if (*p != 'f' && *p != 'F')
				p = tp;
			else if (*(++p) != 'i' && *p != 'I')
			{	/* got "inf" not "infinity", quit */
				seen = 1;
				s = p;
				d = INFINITY;
				goto STRTOD_END;
			}
			else
			{	/* parse rest of "infinity" */
				seen = 1;
				tp = p;
				if (*(++p) != 'n' && *p != 'N'
					|| *(++p) != 'i' && *p != 'I'
					|| *(++p) != 't' && *p != 'T'
					|| *(++p) != 'y' && *p != 'Y') {
					s = tp;
				}
				else
				{	/* got it, replace with "inf" */
					s = ++p;
				}
				d = INFINITY;
				goto STRTOD_END;
			}
		}
	}
	else{
		if (!isdigit(*p))
			goto STRTOD_END;

		for (s = p; isdigit(*s); s++) {
			d = (d * 10) + (float)(*s & 0xf);
		}
	}

	if (*s == '.')
		s++;

	for (base = 1.0F; isdigit(*s); s++) {
		base /= 10.0F;
		e += base * (float)(*s & 0xf);
	}
	d += e;

	if (*s == 'e' || *s == 'E') {
                p = s;
		s++;
		if (*s == '+' || *s == '-') {
			esign = *s++;
		}
                if (!isdigit(*s)) {
                        s = p;
                        goto STRTOD_END;
                }
		for (; isdigit(*s); s++) {
			if (exp > FLT_MAX_10_EXP)
				continue;
			exp = exp * 10 + (int)(*s & 0xf);
		}
	}
	if (d && exp) {
		if (esign == '-') {
			if ((-exp) < (FLT_MIN_10_EXP - 1)) {
				d = 0.0F;
				errno = ERANGE;
				goto STRTOD_END;
			}
		} else {
			if (exp > FLT_MAX_10_EXP) {
				d = HUGE_VALF;
				errno = ERANGE;
				goto STRTOD_END;
			}
		}

		for ( ; exp; ) {
			if (exp / 10) {
				if (esign == '-')
					d /= 10000000000.0F;
				else
					d *= 10000000000.0F;
				exp -= 10;
			} else {
				d = ((esign == '-') ? (d/10.0F) : (d*10.0F));
				exp--;
			}
			if (_REL_isinfinity(d))
				break;
			if (d < FLT_MIN) {
				d = 0.0F;
				errno = ERANGE;
				break;
			}
		}
	}

	STRTOD_END:
	if (endptr)
		*endptr = (char NEARFAR *)s;
	if (sign == '-')
		d = -(d);
	if (!seen && _REL_isinfinity(d))
		errno = ERANGE;
	return d;
}

static int _REL_isinfinity(float d)
{
	unsigned char exp = (unsigned char)
	                                (((*((unsigned int*)&d+1)) << 1) >> 8);

	if (exp == SGL_INFEXP) {
		/* Infinity */
		return 1;
	}
	return 0;
}
