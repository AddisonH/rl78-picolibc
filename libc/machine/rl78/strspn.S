	.file	"strspn.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strspn
	.type	 _strspn,@function

_strspn:
   movw    hl, ax
   movw    ax, bc
   movw    de, ax
   clrw    bc
   decw    hl
1:
   push    de
   incw    hl
   clrb    a
   cmp     a, [hl]
   bz      $3f
2:
   mov     a, [de]
   cmp0    a
   bz      $3f
   incw    de
   cmp     a, [hl]
   bnz     $2b
   pop     de
   incw    bc
   br      $1b
3:
   pop     ax
   movw    ax, bc
   ret

    .size _strspn, . - _strspn
#endif
