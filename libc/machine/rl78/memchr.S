	.file	"memchr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _memchr
	.type	 _memchr,@function

_memchr:

   movw    hl, ax
3:
   clrw    ax
   cmpw    ax, de
   bz      $1f
   mov     a, c
   cmp     a, [hl]
   bz      $2f
   incw    hl
   decw    de
   br      $3b
2:
   movw    ax, hl
1:
   ret

	.size _memchr, . - _memchr
#endif
