    .file	"_COM_memset_f.S"

	.text

	.global  __COM_memset_f
	.type	 __COM_memset_f,@function

;---------------------------------------------------------------------
;	_COM_memset_f
;
;	void __far * __far _COM_memset_f(void __far *s, int c, size_t n);
;
;	input:
;		s = ADE
;		c = BC
;		n = [SP+4]
;
;	output:
;		ADE
;
;---------------------------------------------------------------------

__COM_memset_f:
    mov	    es, a
    movw	ax, [sp+4]
    movw	hl, ax
    push	de
1:
    clrw	ax
    cmpw	ax, hl
    bz		$2f
    mov		a, c
    mov		es:[de], a
    incw	de
    decw	hl
    br		$1b
2:
    pop     de
    mov     a, es
    ret
.Lfunc_end1:
	.size	__COM_memset_f, .Lfunc_end1-__COM_memset_f

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_memset
.type	_memset,@function
.set 	_memset, __COM_memset_f
#endif
