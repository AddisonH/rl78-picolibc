	.file	"strstr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strstr
	.type	 _strstr,@function

_strstr:
   movw    de, ax
   xchw    ax, bc
   movw    hl, ax
   clrw    ax
   cmp     a, [hl]
   bz      $4f
1:
   mov     a, [de]
   cmp0    a
   bz      $5f
   push    hl
2:
   clrb    a
   cmp     a, [hl]
   bz      $3f
   mov     a, [de]
   cmp     a, [hl]
   incw    de
   incw    hl
   bz      $2b
   pop     hl
   incw    bc
   push    bc
   pop     de
   br      $1b
3:
   pop     ax
4:
   movw    ax, bc
5:
   ret

    .size _strstr, . - _strstr
#endif
