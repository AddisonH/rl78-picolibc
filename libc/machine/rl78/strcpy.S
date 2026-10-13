	.file	"strcpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strcpy
	.type	 _strcpy,@function

_strcpy:
   movw    de, ax
   movw    hl, ax
1:
   mov     a, 0[bc]
   mov     [de], a
   incw    bc
   incw    de
   cmp0    a
   bnz     $1b
   movw    ax, hl
   ret

	.size _strcpy, . - _strcpy
#endif
