	.file	"strnlen.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _strnlen
	.type	 _strnlen,@function

_strnlen:
	movw	hl, ax
	movw	de, ax
	movw	ax, bc
	clrw	bc

1:	subw	ax, #1
	bc	$2f
	xchw	ax, bc
	cmp	a, [hl]
	incw	hl
	xchw	ax, bc
	bnz	$1b
	decw	hl
2:	movw	ax, hl
	subw	ax, de
	ret

	.size _strnlen, . - _strnlen
#endif
