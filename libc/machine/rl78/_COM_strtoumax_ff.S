
;---------------------------------------------------------------------
;	_COM_strtoumax_ff
;
;	uintmax_t __far _COM_strtoumax_ff(const char __far * restrict nptr,
;                                         char __far * __far * restrict endptr,
;                                         int base);
;---------------------------------------------------------------------
	.text
	.global	__COM_strtoumax_ff
	.type	__COM_strtoumax_ff,@function
	.extern	__COM_strtoull_ff

__COM_strtoumax_ff:
	br	!!__COM_strtoull_ff
