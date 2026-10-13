

#define LIB_FAR_PARAM

#include <errno.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>
#include <float.h>

#if defined(LIB_FAR_PARAM)
#  define STRTOD           _COM_strtod_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#  define STRTOF           _COM_strtof_ff
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOD           strtod
#  define NEARFAR          __near
#  define STRTOF           strtof
#endif /* defined(LIB_FAR_PARAM) */


#if defined(__RL78_64BIT_DOUBLES__)

#define DBL_INFEXP 0x7ff

static int _REL_isinfinity(double d);



double STRTOD(const char NEARFAR * __restrict s, char NEARFAR * NEARFAR * __restrict endptr)
{
	double d, e;
	double base;
	int exp = 0;
	char sign = '+';
	char esign = '+';
	const char NEARFAR *p = s;
	const char NEARFAR *tp;
	char seen = 0;

	d = e = 0.0;

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
			d = (d * 10) + (double)(*s & 0xf);
		}
	}

	if (*s == '.')
		s++;

	for (base = 1.0; isdigit(*s); s++) {
		base /= 10.0;
		e += base * (double)(*s & 0xf);
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
			if (exp > DBL_MAX_10_EXP)
				continue;
			exp = exp * 10 + (int)(*s & 0xf);
		}
	}
	if (d && exp) {
		if (esign == '-') {
			if ((-exp) < (DBL_MIN_10_EXP - 1)) {
				/* Under-flow */
				d = 0.0;
				errno = ERANGE;
				goto STRTOD_END;
			}
		} else {
			if (exp > DBL_MAX_10_EXP) {
				/* Over-flow */
				d = (double)HUGE_VAL;
				errno = ERANGE;
				goto STRTOD_END;
			}
		}

		for ( ; exp; ) {
			if (exp / 10) {
				if (esign == '-')
					d /= (double)10000000000.0;
				else
					d *= (double)10000000000.0;
				exp -= 10;
			} else {
				d = ((esign == '-') ? (d / 10.0) : (d * 10.0));
				exp--;
			}
			if (_REL_isinfinity(d))
				break;
			if (d < DBL_MIN) {
				/* Under-flow */
				d = 0.0;
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

static int _REL_isinfinity(double d)
{
	unsigned int exp = (((*((unsigned int*)&d+3)) << 1) >> 5);

	if (exp == DBL_INFEXP) {
		/* Infinity */
		return 1;
	}
	return 0;
}


#else /* !defined(__RL78_64BIT_DOUBLES__) */

double STRTOD(const char NEARFAR *s, char NEARFAR * NEARFAR *endptr)
{
	return STRTOF(s, endptr);
}

#endif /* defined(__RL78_64BIT_DOUBLES__) */
