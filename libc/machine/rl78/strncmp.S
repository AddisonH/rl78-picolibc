	.file	"strncmp.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strncmp
	.type	 _strncmp,@function

_strncmp:

   xchw    ax, de
   xchw    ax, bc
   movw    hl, ax
1:
   clrw    ax
   cmpw    ax, bc
   bz      $2f
   mov     a, [de]
   mov     x, a
   sub     a, [hl]
   bnz     $3f
   incw    de
   incw    hl
   decw    bc
   cmp0    x
   bnz     $1b
3:
   mov     x, a
   subc    a, a
2:
   ret

	.size _strncmp, . - _strncmp
#endif
