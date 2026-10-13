	.file	"setjmp.S"

	.section .text
	
   .global	_setjmp
	.type	_setjmp, @function

_setjmp:
#ifndef __FAR_DATA__
   movw    de, ax
   movw    ax, sp
   movw    [de], ax
   movw    ax, [sp]
   movw    [de+2], ax
   movw    ax, [sp+2]
   movw    [de+4], ax
#else
   mov     es, a
   movw    ax, sp
   movw    es:[de], ax    ; save the stack pointer
   movw    ax, [sp]
   movw    es:[de+2], ax  ; return address (ofs)
   movw    ax, [sp+2]
   movw    es:[de+4], ax  ; return address (seg)
#endif
   clrw    ax             ; return 0
   ret 

	.size	_setjmp, . - _setjmp

	.global	_longjmp
	.type _longjmp, @function

_longjmp:
#ifndef __FAR_DATA__
   movw    de, ax
   movw    ax, [de]
   movw    sp, ax
   movw    ax, [de+2]
   movw    [sp], ax
   movw    ax, [de+4]
   movw    [sp+2], ax
#else
   mov     es, a
   movw    ax, es:[de]
   movw    sp, ax        ; restore the stack pointer
   movw    ax, es:[de+2]
   movw    [sp], ax      ; the return address ofs
   movw    ax, es:[de+4]
   movw    [sp+2], ax    ; and return address seg
#endif
   movw    ax, bc        ; setjmp() may not return 0
   cmpw    ax, #0        ; if returning from longjmp()
   sknz
   incw    ax
   ret

	.size	_longjmp, . - _longjmp
