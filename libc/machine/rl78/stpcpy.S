	.file	"stpcpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _stpcpy
	.type	 _stpcpy,@function

_stpcpy:

	movw	hl, ax
1:	mov	    a, [bc]
	incw	bc
	mov	    x, a
	movs	[hl+0], x
	incw	hl
	bnz	    $1b
	decw	hl
	movw	ax, hl
	ret

	.size _stpcpy, . - _stpcpy
#endif
