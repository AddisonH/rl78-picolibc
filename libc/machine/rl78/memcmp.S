	.file	"memcmp.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _memcmp
	.type	 _memcmp,@function

_memcmp:
   xchw    ax, de
   xchw    ax, bc
   movw    hl, ax
2:
   clrw    ax
   cmpw    ax, bc
   bz      $1f
   mov     a, [de]
   sub     a, [hl]
   incw    de
   incw    hl
   decw    bc
   bz      $2b
   mov     x, a
   subc    a, a
1:
   ret

	.size _memcmp, . - _memcmp
#endif
