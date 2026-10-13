	.file	"stpncpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _stpncpy
	.type	 _stpncpy,@function

_stpncpy:

	movw	hl, ax
	movw	ax, bc
	xchw	ax, de

1:	subw	ax, #1
	bc	$3f
	xchw	ax, bc
	mov	a, [de]
	incw	de
	mov	x, a
	movs	[hl+0], x
	incw	hl
	xchw	ax, bc
	bnz	$1b
	decw	hl
	push	hl
	pop	de
2:	mov	[de], #0
	incw	de
	subw	ax, #1
	bnc	$2b
3:	movw	ax, hl
	ret

	.size _stpncpy, . - _stpncpy
#endif
