	.file	"strncpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strncpy
	.type	 _strncpy,@function

_strncpy:

   push    ax
   movw    hl, ax
1:
   clrw    ax
   cmpw    ax, de
   bz      $2f
   mov     a, 0[bc]
   mov     [hl], a
   incw    hl
   decw    de
   cmp0    a
   skz
   incw    bc
   br      $1b
2:
   pop     ax
   ret

	.size _strncpy, . - _strncpy
#endif
