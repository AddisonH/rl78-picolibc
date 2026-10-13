;---------------------------------------------------------------------
;	_COM_strtoimax_ff
;
;	intmax_t __far _COM_strtoimax_ff(const char __far * restrict nptr,
;                                        char __far * __far * restrict endptr,
;                                        int base);
;---------------------------------------------------------------------
	.text
	.global	__COM_strtoimax_ff
	.type	__COM_strtoimax_ff,@function
	.extern	__COM_strtoll_ff

__COM_strtoimax_ff:
	br	!!__COM_strtoll_ff
