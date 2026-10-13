	.file	"strrchr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strrchr
	.type	 _strrchr,@function

_strrchr:
   movw    hl, ax
   clrw    ax
   movw    de, ax
2:
   mov     a, [hl]
   cmp     a, c
   bnz     $1f
   push    hl
   pop     de
1:
   incw    hl
   cmp0    a
   bnz     $2b
   movw    ax, de
   ret

	.size _strrchr, . - _strrchr
#endif
