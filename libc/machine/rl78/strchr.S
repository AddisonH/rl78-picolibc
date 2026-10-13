	.file	"strchr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strchr
	.type	 _strchr,@function

_strchr:
   movw    hl, ax
2:
   mov     a, [hl]
   cmp     a, c
   bz      $1f
   incw    hl
   cmp0    a
   bnz     $2b
   clrw    ax
   ret
1:
   movw    ax, hl
   ret

	.size _strchr, . - _strchr
#endif
