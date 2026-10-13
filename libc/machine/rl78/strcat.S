	.file	"strcat.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strcat
	.type	 _strcat,@function

_strcat:

  movw	hl, ax
  movw	de, ax
  clrb	a
 1:
  cmp	a, [hl]
  incw	hl
  bnz	$1b
  decw	hl
2:
  mov	a, 0[bc]
  mov	[hl], a
  incw	bc
  incw	hl
  cmp0	a
  bnz	$2b
  movw	ax, de
  ret

	.size _strcat, . - _strcat
#endif
