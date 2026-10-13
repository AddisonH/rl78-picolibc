#define LIB_FAR_PARAM

#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <ctype.h>



#if defined(LIB_FAR_PARAM)
#  define STRTOULL         _COM_strtoull_ff
#if defined(__FAR_DATA__)
#  define NEARFAR
#else
#  define NEARFAR          __far
#endif
#else /* !defined(LIB_FAR_PARAM) */
#  define STRTOULL         strtoull
#  define NEARFAR          __near
#endif /* defined(LIB_FAR_PARAM) */


unsigned long long STRTOULL(const char NEARFAR * __restrict nptr, char NEARFAR* NEARFAR* __restrict endptr,int base)
{
	unsigned long long int l;
	char almax;
	unsigned long long int wl;
	long errflg,one,nflg;
	const char NEARFAR *sptr;
	int enbl = 0;

	l=0ULL;
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
			wl=0ULL ;
			while ((isalnum(*nptr)!=0) && (tolower((char)*nptr)<=almax)) {
				if (errflg==0) {
					if (isdigit(*nptr))  one= *nptr-'0';
					else  one=tolower((char)*nptr)-'a'+10;

					if (wl>0 && ((((wl*base)/base)!=wl) ||
								 ((wl*base)-nflg>
							(unsigned long long)ULLONG_MAX-one)))
						errflg=1;
					else  wl=wl*base+one;
				}
				nptr++;
			}
			if (errflg==0) {
				if (nflg==0)  l=wl;
				else  l= ( -1*wl);
			}
			else {
				errno=ERANGE;
				l=ULLONG_MAX;
			}
		}
	}
 	if (endptr!=NULL) {
		 if (enbl)	*endptr=(char NEARFAR*)nptr;
		 else		*endptr=(char NEARFAR*)sptr;
	}
	return(l);
}
