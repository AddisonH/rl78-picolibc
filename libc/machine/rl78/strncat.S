	.file	"strncat.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strncat
	.type	 _strncat,@function

_strncat:
   push    ax
   movw    hl, ax
   clrb    a
1:
   cmp     a, [hl]
   incw    hl
   bnz     $1b
   decw    hl
3:
   clrw    ax
   cmpw    ax, de
   bz      $2f
   mov     a, 0[bc]
   cmp0    a
   bz      $2f
   mov     [hl], a
   incw    bc
   incw    hl
   decw    de
   br      $3b
2:
   mov     [hl], a
   pop     ax
   ret

	.size _strncat, . - _strncat
#endif
