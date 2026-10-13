	.file	"strlen.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strlen
	.type	 _strlen,@function

_strlen:
   movw    de, ax
   movw    bc, ax
1:
   mov     a, [de]
   incw    de
   cmp0    a
   bnz     $1b
   decw    de
   movw    ax, de
   subw    ax, bc
   ret

	.size _strlen, . - _strlen
#endif
