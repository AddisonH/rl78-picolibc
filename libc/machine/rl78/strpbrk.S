	.file	"strpbrk.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strpbrk
	.type	 _strpbrk,@function

_strpbrk:
   movw    hl, ax
   clrw    ax
   decw    hl
2:
   incw    hl
   push    bc
   pop     de
   cmp     a, [hl]
   bz      $1f
3:
   mov     a, [de]
   cmp0    a
   bz      $2b
   incw    de
   cmp     a, [hl]
   bnz     $3b
   movw    ax, hl
1:
   ret

    .size _strpbrk, . - _strpbrk
#endif
