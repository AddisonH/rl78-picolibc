;---------------------------------------------------------------------
;	_COM_strtold_ff
;
;	long double __far _COM_strtold_ff(const char __far * restrict nptr,
;	                                  char __far * __far * restrict endptr);
;
;---------------------------------------------------------------------

	.global	__COM_strtold_ff
#ifdef __RL78_32BIT_DOUBLES__
	.extern	__COM_strtof_ff
#else
	.extern	__COM_strtod_ff
#endif

	.text
__COM_strtold_ff:
#ifdef __RL78_32BIT_DOUBLES__
	br	!!__COM_strtof_ff
#else
	br	!!__COM_strtod_ff
#endif
