#define LIB_FAR_PARAM

//#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <ctype.h>



#if defined(LIB_FAR_PARAM)
#  define STRTOLL          _COM_strtoll_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOLL          strtoll
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */


long long STRTOLL(const char NEARFAR * __restrict nptr, char NEARFAR* NEARFAR * __restrict endptr, int base)
{
	long long l;
	char almax;
	unsigned long long int wl;
	long errflg,one,nflg;
	const char NEARFAR *sptr;
	int enbl = 0;

	l=0LL;
	nflg=0;
	sptr = nptr;

	while(isspace(*nptr)) {
		nptr++;
	}

	if ((*nptr=='+') || (*nptr=='-')) {
		if (*nptr=='-')  nflg= 1;
		nptr++;
	}

	if (base==0) {
		if (*nptr=='0') {
			nptr++;
			if (tolower((char)*nptr)=='x') {
				nptr++;
				base=16;
			}
			else {
				base=8;
			}
		}
		else base=10 ;
	}
	else if (base==16) {
		if (*nptr=='0') {
			nptr++;
			if (tolower((char)*nptr)=='x')  nptr++;
		}
	}

	if ((base>=2) && (base<=36)) {
		if (base>10)  almax='a'+base-11;
		else  almax='9'+base-10;

		if ((isalnum(*nptr)!=0) && (tolower((char)*nptr) <= almax)) {
			enbl = 1;
			while (*nptr=='0') {
				nptr++;
			}
			errflg=0;
			wl=0LL ;
			while ((isalnum(*nptr)!=0) && (tolower((char)*nptr)<=almax)) {
				if (errflg==0) {
					if (isdigit(*nptr))  one= *nptr-'0';
					else  one=tolower((char)*nptr)-'a'+10;

					if (wl>(((unsigned long long)LLONG_MAX-one+nflg)/base))
						errflg=1;
					else  wl=wl*base+one;
				}
				nptr++;
			}
			if (errflg==0) {
				 if (nflg==0)  l=(long long)wl;
				 else  l= (long long)( -1*wl);
			}
			else {
				errno=ERANGE;
				if (nflg==0) l=LLONG_MAX;
				else  l=LLONG_MIN;
			}
		}
	}
 	if (endptr!=NULL) {
		 if (enbl)	*endptr=(char NEARFAR*)nptr;
		 else		*endptr=(char NEARFAR*)sptr;
	}
	return(l);
}
